/*		15_edu_create_treatment_variables.do: combine data and calculate treatment effect
		created: 		hhs 24/2/2018 
		edited:			hhs 20/3/2018 
						hhs 27/4/2018 
						hhs 10/7/2020
*/
* load globals
		do  "K:\Workdata\706831\grading\do_files/globals.do"
* a small program to create data
cap program drop myprog
program myprog
	syntax, treated(string) year(string) 
	* load data
	use "$tf\cohort.dta",clear
			gen edu_ku=edu_instid==101455 /*  KU  */
			gen edu_udelt=edu_part==60
			replace edu_part=62 if edu_part==60 
			
			keep if edu_part==62
			bys pnr: keep if _n==1		
			if `treated'==1{
				keep if treat_treated==`treated'
			}
			if `treated'==0{
				keep if treat_placebo`year'==1
			}
	* merge to grade data from the university
			merge 1:m pnr edu_ku using  "$tf\unused_grades.dta", keep (1  3) nogen
	* drop grades that have been used
			drop if used==1
	* pre indicator
		gen edu_pre=bedoemmelsesdato<mdy(8,1,`year')
	* sort and accumulate ECTS
		drop if used==1
		gen ects_raw=edu_ects
		replace edu_ects=0 if karakter=="B"
		drop if bedoemmelsesdato<edu_startdate 
		sort pnr bedoemmelsesdato
		by pnr: gen edu_ects_cum=sum(edu_ects)
	* keep only grades that are part of the  program
		gen keepvar=1
		replace keepvar=0 if edu_ects_cum>180 & bedoemmelsesdato>edu_stopdate & edu_education==237 /* Medicin */
		replace keepvar=0 if edu_ects_cum>120 & bedoemmelsesdato>edu_stopdate & edu_education!=237 /* Ej medicin */
		replace keepvar=0  if bedoemmelsesdato>(edu_stopdate+30)
		keep if keepvar==1
		drop keepvar
	* ects
		gen ects_raw_pre=ects_raw if edu_pre==1
		gen ects_raw_post=ects_raw if edu_pre==0
		gen e=edu_ects if edu_pre==1 					/* ECTS for passed and graded units pre */
		bys pnr:  egen edu_pre_ects=sum(e) 
		gen f=edu_ects if edu_pre==0 					/* ECTS for graded and passed units post */
		bys pnr: egen edu_post_ects=sum(f)	
		bys pnr: egen edu_ects_tot=sum(edu_ects)		/*	total ECTS */
	* course toughness
		merge m:1 subject using "$tf\grades_toughness.dta",keep(1 3) nogen	
	* gpa
		gen passed_grades=karakter if inlist(karakter,"02","4","7","10","11","12","13")
		gen passed_grades_opr=OPR_KARAKTER if inlist(karakter,"02","4","7","10","11","12","13")
		destring passed_grades passed_grades_opr,replace force
		gen edu_pregpa7=passed_grades if edu_pre==1				/* Pre GPA, recoded 	(=7scale)	*/
		gen edu_pregpa13=passed_grades_opr if edu_pre==1 	/* Pre GPA, not recoded (=13scale)	*/ 
		gen edu_postgpa=passed_grades if edu_pre==0		 		/* Post GPA	(=7scale)	*/ 	
	* the following should not be necesary (very few are affected)
		drop if edu_pregpa7!=. & edu_pregpa13==.
		drop if edu_pregpa7==. & edu_pregpa13!=.
	* dissertation
		gen edu_dissertation=strpos(fagnavn_ch,"speciale")!=0|  strpos(fagnavn_ch,"Speciale")!=0
		replace edu_dissertation=. if  edu_pre==1
	* weighted grade
		gen edu_pregpa7w	=edu_pregpa7*			(edu_ects/edu_pre_ects) 	/* Pre GPA, recoded 		(=7scale)	*/
		gen edu_pregpa13w	=edu_pregpa13*			(edu_ects/edu_pre_ects) 	/* Pre GPA, not recoded 	(=13scale)	*/
		gen edu_postgpaw	=edu_postgpa*			(edu_ects/edu_post_ects) 	/* Post GPA 				(=7scale)	*/
		gen edu_gpaw=passed_grades*				 	(edu_ects/edu_ects_tot) 	/* Overall GPA 				(=7scale)	*/
	* failed
		gen edu_failed_post= !inlist(karakter,"02","4","7","10","11","12","13","B") 
		replace edu_failed_post=. if edu_pre==1
	* how tough?
		replace edu_subgrade_fe=. if edu_pre==1
	* one obs per individual
		collapse (mean) edu_udelt edu_dissertation edu_failed_post edu_postgpa edu_pregpa13 edu_pregpa7 edu_subgrade_fe ///
				 (sum) edu_pregpa7w edu_pregpa13w edu_postgpaw  edu_gpaw ///
					   edu_ects_tot_graded=edu_ects edu_ects_tot=ects_raw ///
					   edu_ects_tot_graded_pre=e 	edu_ects_tot_pre=ects_raw_pre ///
					   edu_ects_tot_graded_post=f 	edu_ects_tot_post=ects_raw_post /// 
				(max) edu_education edu_field edu_startdate edu_stopdate edu_audd	edu_ku ///
				 ,by(pnr) fast
	* adjustments
		gen edu_pre_share=edu_ects_tot_graded_pre/ edu_ects_tot_graded
		gen edu_ects_to_go=180-edu_ects_tot_pre if  edu_education==237 
		replace edu_ects_to_go=120-edu_ects_tot_pre if  edu_education!=237 
		replace edu_ects_to_go=300-edu_ects_tot_pre if  edu_udelt==1
		replace edu_ects_to_go=0 if edu_ects_to_go<0
	* save
		keep pnr edu*
		bys pnr: keep if _n==1
		compress
		save "$tf\gradedata_treated`treated'`year'.dta",replace
end
* create datasets
myprog,treated(1) year(2007) 
forval i=2001/2006{
	myprog,treated(0) year(`i') 
}

*
		* histogram over dissertation
		use "$tf\unused_grades.dta",clear
		keep if strpos(fagnavn_ch,"speciale")!=0|  strpos(fagnavn_ch,"Speciale")!=0
		collapse (count) n=edu_ku,by(edu_ects)
		sum n
		gen share=n/r(sum)
		drop if n<6
		tw (bar share edu_ects,fcolor(black) lcolor(white)), ///
		graphregion(lcolor(white) fcolor(white)) ///
		plotregion(lcolor(white) fcolor(white))
		graph export "$df\fig_speciale_ects.png",width(2000) replace

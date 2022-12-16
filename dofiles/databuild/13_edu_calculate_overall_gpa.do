/*		13_edu_calculate_overall_gpa: find all completed spells (to calcualte GPAs)
		created: 		hhs 16/5/2018
		edited:		ath 30/8/2018
					hhs 13/9/2018: line 50 and 85
*/

* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"

/* Bachelor */ 
	* load data 
	use "$tf\graduates_level61.dta",clear
	merge 1:m pnr using "$tf\grades.dta",nogen keep(3)
	* sort and accumulate ECTS
		replace edu_ects=0 if karakter=="B"
		replace karakter=OPR_KARAKTER if elev3_vtil<mdy(8,1,2007) & OPR_KARAKTER!=""
		drop if inlist(karakter,"2","4","12") & elev3_vtil<mdy(8,1,2007) 
		drop if inlist(karakter,"-3","02") & elev3_vtil<mdy(8,1,2007)	
		drop if bedoemmelsesdato<elev3_vfra 
		sort pnr bedoemmelsesdato
		by pnr: gen edu_ects_cum=sum(edu_ects)
	* keep only grades that are part of the bachelor program
		gen keepvar=1
		replace keepvar=0 if edu_ects_cum>180 & bedoemmelsesdato>elev3_vtil
		replace keepvar=0  if bedoemmelsesdato>(elev3_vtil+30)
	* save unused grades
		preserve
			keep if keepvar==1  
			keep gradeid
			merge 1:1 gradeid using "$tf\grades.dta",
			gen used=_merge==3
			drop _merge
			save "$tf\unused_grades.dta",replace
		restore
	* continue
		keep if keepvar==1
		drop if edu_ects==0
		drop keepvar
		destring karakter OPR_KARAKTER, replace
	* calculate GPA
		bys pnr: egen ectssum=sum(edu_ects)
		gen weighted=karakter*edu_ects/ectssum
		bys pnr: egen gpa=sum(weighted)
	* keep what we need
		bys pnr: keep if _n==1
		keep pnr education ele* disci gpa
	* standardize
		gen scale7=elev3_vtil>=mdy(8,1,2007)
		gen year=year(elev3_vtil)
		bys education year scale7:  egen m=mean(gpa)
		bys education year scale7: egen sd=sd(gpa)
		gen cov_undergrad_gpa=(gpa-m)/sd
		keep cov_undergrad_gpa pnr
	save "$tf\gpa_level61.dta",replace

	
/* Kandidat/MA */ 
	* load data
	use "$tf\graduates_level62.dta",clear
	merge 1:m pnr using "$tf\unused_grades.dta",nogen keep(3)
	* sort and accumulate ECTS
		drop if used==1
		replace edu_ects=0 if karakter=="B"
		replace karakter=OPR_KARAKTER if elev3_vtil<mdy(8,1,2007) & OPR_KARAKTER!=""
		drop if inlist(karakter,"2","4","12") & elev3_vtil<mdy(8,1,2007) 
		drop if inlist(karakter,"-3","02") & elev3_vtil<mdy(8,1,2007)
		drop if bedoemmelsesdato<elev3_vfra 
		sort pnr bedoemmelsesdato
		by pnr: gen edu_ects_cum=sum(edu_ects)
	* keep only grades that are part of the  program
		gen keepvar=1
		replace keepvar=0 if edu_ects_cum>180 & bedoemmelsesdato>elev3_vtil & education==237 /* Medicin */
		replace keepvar=0 if edu_ects_cum>120 & bedoemmelsesdato>elev3_vtil & education!=237 /* Ej medicin */
		replace keepvar=0  if bedoemmelsesdato>(elev3_vtil+30)
		keep if keepvar==1
		drop keepvar
		drop if edu_ects==0
	* calculate GPA
		destring karakter OPR_KARAKTER, replace
		bys pnr: egen ectssum=sum(edu_ects)
		gen weighted=karakter*edu_ects/ectssum
		bys pnr: egen gpa=sum(weighted)
		gen scale7=elev3_vtil>=mdy(8,1,2007)
	* keep what we need
		bys pnr: egen grades_count=count(karakter)
		bys pnr: keep if _n==1
		keep pnr education_group ele* disci gpa scale7 grades_count
		rename education_group education
	save "$tf\gpa_level62.dta",replace

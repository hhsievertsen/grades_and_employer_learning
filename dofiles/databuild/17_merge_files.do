/*		17_merge_files.do: merge all datasets; 
		created: 		hhs 24/2/2018 
		edited:			hhs 18/4/2018 (cleaning)
						hhs 13/9/2018 (added job changes)
						ath 27/11/2018(cleaning)
						ath 14/1/2019 (added earnings while studying)
						hhs 20/7/2020 (added earnings quarterly)
*/
* load globals
		do  "K:\Workdata\706831\grading\do_files/globals.do"
* a small program to create the data
cap program drop myprog
program myprog
syntax, treated(string) year(string) 
	local my=`year'-1
	* load first dataset
		use "$tf\gradedata_treated`treated'`year'.dta",clear 
	*merge education with study earnings
		merge m:1 edu_audd using "$tf\edu_study_earnings.dta",nogen keep(1 3)
	*merge education with public worker share measure
		merge m:1 edu_audd using  "$tf\edusectorshare.dta",nogen keep(1 3)
	* merge education with dispersion measure	
		merge m:1 edu_audd using  "$tf\earningsdispersion.dta",nogen keep(1 3)
	* add basic covariates
		merge 1:1 pnr using  "$tf\basic_covariates.dta",nogen keep(1 3)
	* add parental covars
		merge 1:1 pnr using "$tf\par_cov_y`my'.dta",nogen keep(1 3)
	* hs gpa
		merge 1:1 pnr using "$tf\gpa.dta", nogen keep(1 3)
		merge 1:1 pnr using "$tf\hs_written.dta", nogen keep(1 3)
	* undergrad GPA
		merge 1:1 pnr using "$tf\gpa_level61.dta", nogen keep(1 3)
	* earnings and income
		gen edu_year=year(edu_stopdate)
		forval i=0/5{
				gen year=edu_year+`i'
				merge 1:1 pnr year using "$tf\earningslong.dta", nogen keep(1 3)
				rename learnings outcome_learnings_`i'
				rename earnings outcome_earnings_`i'
				gen   outcome_worked_`i'= outcome_earnings_`i'!=. &  outcome_earnings_`i'>0
				* disp income
				merge 1:1 pnr year using "$tf\dispincomelong.dta", nogen keep(1 3)
				rename ldispincome outcome_ldispincome_`i'
				rename dispincome outcome_dispincome_`i'
				rename lwageincome outcome_lgrossincome_`i'
				rename wageincome outcome_grossincome_`i'
				* unemployment
				merge 1:1 pnr year using "$tf\unempl.dta", nogen keep(1 3)
				rename selfemployed outcome_selfemployed_`i'
				rename unemployment outcome_unemployment_`i'
				rename ever_unemployed outcome_ever_unemployed_`i'
				* job changes
				merge 1:1 pnr year using "$tf\raspanel.dta", nogen keep(1 3)
				rename public_sector outcome_public_sector_`i'
				rename jobchange outcome_jobchange_`i'
				rename occupation outcome_occupation_`i'
				drop year  
			}
	/* Adjust education variables */
		gen edu_graduated=!inlist(edu_audd,0,9999)
		gen edu_enrolyear=year(edu_startdate)
		gen edu_stopyear=year(edu_stopdate)
		replace edu_graduated=0 if edu_stopyear>2010 & edu_stopyear!=.
	/* Adjust covariates  */
		gen cov_age=(edu_stopdate-cov_date_)/365.24
		gen cov_parental_incobserved=(father_income!=.) + (mother_income!=.)
		replace father_income=0 if father_income==.
		replace mother_income=0 if mother_income==.
		gen cov_parental_income=(father_income!=.)*father_income + mother_income*(mother_income!=.)
		replace cov_parental_income=cov_parental_income/cov_parental_incobserved
		gen cov_parental_uneobserved=(father_une!=.) + (mother_une!=.)
		replace mother_une=0 if mother_une==.
		replace father_une=0 if father_une==.
		gen cov_parental_une=(father_une!=.)*father_une + mother_une*(mother_une!=.)
		replace cov_parental_une=cov_parental_une/cov_parental_uneobserved
		gen cov_parental_schoolingobserved=(father_schooling!=.) + (mother_schooling!=.)
		replace father_schooling=0 if father_schooling==.
		replace mother_schooling=0 if mother_schooling==.
		gen cov_parental_schooling=(father_schooling!=.)*father_schooling + mother_schooling*(mother_schooling!=.)
		replace cov_parental_schooling=cov_parental_schooling/cov_parental_schoolingobserved
		gen cov_parental_schooling_uni=father_schooling_uni==1
		replace cov_parental_schooling_uni=1 if mother_schooling_uni==1 
	/* cleaning */
		drop    fath* moth*  cov_date_ 
	
	/* MISSINGS	*/
		replace edu_gpaw=. if edu_graduated==0
		foreach var in cov_female cov_nonwestern cov_gpa cov_age cov_undergrad_gpa cov_hs_gpawritten {
				gen int `var'_m=`var'==.
				replace  `var'=0 if `var'==.
		}
		replace cov_parental_income=0 if cov_parental_incobserved==0
		gen int cov_parental_income_m=cov_parental_incobserved==0
		replace cov_parental_une=0 if cov_parental_uneobserved==0
		gen int cov_parental_une_m=cov_parental_uneobserved==0
		replace cov_parental_schooling=0 if cov_parental_schoolingobserved==0		
		gen int cov_parental_schooling_m=cov_parental_schoolingobserved==0	
	* save
		order pnr edu* cov* outcome*
		compress

	save "$tf\rawdata_treated`treated'`year'.dta",replace
end
* run
myprog,treated(1) year(2007) 
forval i=2001/2006{
	myprog,treated(0) year(`i') 
}


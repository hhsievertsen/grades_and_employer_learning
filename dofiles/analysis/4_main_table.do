/* 		4_main_table
		created: 		hhs 12/11/2018
						hhs 24/1/2019
						hhs 18/8/2020
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"

/* save estimates */
clear 
set obs 5
gen beta_main=.
gen beta_placebo_=.
gen upper_main=.
gen upper_placebo=.
gen lower_main=.
gen lower_placebo=.
gen year=_n
save "$df\estimates.dta",replace


// Load data
use  "$tf\graduate_data12007.dta",clear
eststo clear
// Loop over years
forval i=1/5{
	// Regression to get the sample
	qui: reg outcome_learnings_`i' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
	// Residual variation
	reg edu_pregpa7w 	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2 if e(sample), cluster(edu_gpa_group)
	predict res, residual
	sum res
	local sd=r(sd)
	// main regression
	eststo: reg outcome_learnings_`i' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
			matrix a=r(table)
	estadd scalar mysd=`sd'
	drop res
	preserve
		use "$df\estimates.dta",clear
		replace beta_main= a[1,1] if year==`i'
		replace upper_main= a[5,1] if year==`i'
		replace lower_main= a[6,1] if year==`i'
		save "$df\estimates.dta",replace

	restore
}
// generate table
esttab using "$df\tab_main_reg.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w	  ) label ///
	subs("N" "\hline Observations" "r2" "R-squared"  "mysd" "SD(recoded GPA)")

	
	
	
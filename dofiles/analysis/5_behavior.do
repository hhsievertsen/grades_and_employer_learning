/* 		5_behavior: behavioral response
		created: 		hhs 14/9/2018 
		edited: 		hhs 18/8/2020
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// load data
use "$tf\labeldata12007.dta",clear
drop if edu_pregpa7_std==.
keep if  edu_ects_to_go<=40
// consider only other outcomes only if graduated
foreach var in	 edu_time_to_grad edu_subgrade_fe edu_postgpaw {
	replace `var'=. if edu_graduated==0
}
// loop over outcomes
eststo clear
foreach var in edu_graduated edu_time_to_grad edu_subgrade_fe edu_postgpaw { 
	// reg just to get the sample
	reg `var' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
	// residual variation for sample
	reg edu_pregpa7w 	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2 if e(sample), cluster(edu_gpa_group)
	predict res, residual
	sum res
	local sd=r(sd)
	// mean of dep var in sample
	sum `var' if e(sample)
	local mdv=r(mean)
	// main regression
	eststo: reg `var' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
	// add scalars
	estadd scalar mysd=`sd'
	estadd scalar meandepvar=`mdv'
	drop res
}
// generate table
esttab using "$df\tab_behaviour.tex",  fragment nomtitles  replace ///
		star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd meandepvar,fmt(%4.0f %4.2f  %4.2f  %4.2f    )) ///
			nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w	  ) label ///
			subs("N" "\hline Observations" "r2" "R-squared" "mysd" "SD(recoded GPA)" "meandepvar" "Mean dep. var")
					
	
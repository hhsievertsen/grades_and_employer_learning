/* 		7_placebo
		created: 		hhs 12/11/2018
						hhs 24/1/2019
						hhs 18/8/2020
*/

// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// loop over placebo cohorts 
forval i=2002/2004{
	use  "$tf\graduate_data0`i'.dta",clear
	* remove if graduated after reform *
	drop if mdy(1,1,2007)<edu_stopdate
	eststo clear
	// loop over years
	forval j=1/5{
		// regression just to get the sample
		 qui:reg outcome_learnings_`j' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		// residual variation
		qui: reg edu_pregpa7w 	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2 if e(sample), cluster(edu_gpa_group)
		predict res, residual
		qui:sum res
		local sd=r(sd)
		// main regression
		eststo: qui: reg outcome_learnings_`j' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		qui: estadd scalar mysd=`sd'
		drop res
	}
	/* output  table*/
	esttab using "$df\tab_placebo`i'.tex",  fragment nomtitles ///
					replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
					nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w	  ) label ///
	subs("N" "\hline Observations" "r2" "R-squared"  "mysd" "SD(recoded GPA)")
}
					


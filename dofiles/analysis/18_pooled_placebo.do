/* 		17_DiD
		created: 		ath: 07/05/2021
*/

// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// append placebo cohorts 
use  "$tf\graduate_data02002.dta",clear
gen year=2002
drop if mdy(1,1,2007)<edu_stopdate	
forval i=2003/2004{
	append using "$tf\graduate_data0`i'.dta"
	replace year=`i' if year==.
	* remove if graduated after reform *
	drop if mdy(1,1,2007)<edu_stopdate	
}
*Run regression with all obs - duplicates over the years incl.
	eststo clear
	// loop over years
	forval j=1/5{
		// regression just to get the sample
		 qui:reg outcome_learnings_`j' edu_pregpa7w edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		// residual variation 
		qui: reg edu_pregpa7w  edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2 if e(sample), cluster(edu_gpa_group)
		predict res, residual
		qui:sum res
		local sd=r(sd)
		// main regression
		eststo: qui: reg outcome_learnings_`j' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		qui: estadd scalar mysd=`sd'
		drop res
	
	/* output  table*/
	esttab using "$df\tab_placebo_dups`i'.tex",  fragment nomtitles ///
					replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
					nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w) label ///
	subs("N" "\hline Observations" "r2" "R-squared"  "mysd" "SD(recoded GPA)")
}





*Regression without duplicates
sort pnr year
by pnr (year): keep if _n==1
	eststo clear
	// loop over years
	forval j=1/5{
		// regression just to get the sample
		 qui:reg outcome_learnings_`j' edu_pregpa7w edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		// residual variation 
		qui: reg edu_pregpa7w edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2 if e(sample), cluster(edu_gpa_group)
		predict res, residual
		qui:sum res
		local sd=r(sd)
		// main regression
		eststo: qui: reg outcome_learnings_`j' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		matrix a=r(table)
		qui: estadd scalar mysd=`sd'
		drop res
		preserve
	use "$df\estimates.dta",clear
		replace beta_placebo= a[1,1] if year==`j'
		replace upper_placebo= a[5,1] if year==`j'
		replace lower_placebo= a[6,1] if year==`j'
		save "$df\estimates.dta",replace
		restore
	/* output  table*/
	esttab using "$df\tab_placebo_nodups`i'.tex",  fragment nomtitles ///
					replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
					nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w) label ///
	subs("N" "\hline Observations" "r2" "R-squared"  "mysd" "SD(recoded GPA)")
}

*Regressions with year FE 
duplicates drop pnr, force
	eststo clear
	// loop over years
	forval j=1/5{
		// regression just to get the sample
		 qui:reg outcome_learnings_`j' edu_pregpa7w edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 i.year $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		// residual variation 
		qui: reg edu_pregpa7w edu_pregpa13w  edu_pregpa13w2 edu_pregpa13w3 i.year $cov0 $cov1 $cov2 if e(sample), cluster(edu_gpa_group)
		predict res, residual
		qui:sum res
		local sd=r(sd)
		// main regression
		eststo: qui: reg outcome_learnings_`j' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 i.year $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		qui: estadd scalar mysd=`sd'
		drop res
	
	/* output  table*/
	esttab using "$df\tab_placebo_yearFE`i'.tex",  fragment nomtitles ///
					replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
					nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w) label ///
	subs("N" "\hline Observations" "r2" "R-squared"  "mysd" "SD(recoded GPA)")
}

/* Figure */
use "$df\estimates.dta",clear					
expand 2
bys year: gen id=_n
gen y=year-0.25 if id==1
replace y=year+0.25 if id==2
tw  (rspike upper_main lower_main y if id==1) ///
   (rspike upper_placebo lower_placebo y if id==2) ///
    (scatter beta_main y if id==1) ///
   (scatter beta_placebo y if id==2)




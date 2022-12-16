/* 		17_DiD
		created: 		ath: 07/05/2021
*/

// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// append placebo cohorts and treated
use  "$tf\graduate_data12007.dta",clear
gen treated=1
gen year=2007
forval i=2002/2004{
	append using "$tf\graduate_data0`i'.dta"
	replace year=`i' if year==.
	drop if mdy(1,1,2007)<edu_stopdate & treated!=1	
}
replace treated=0 if treated==.
gen treatedXc_edu_pregpa7w=edu_pregpa7w*treated
gen treatedXedu_pregpa13w=edu_pregpa13w*treated
gen treatedXedu_pregpa13w2=edu_pregpa13w2*treated
gen treatedXedu_pregpa13w3=edu_pregpa13w3*treated
label var treatedXc_edu_pregpa7w "Treated X Recoded GPA"
label var treated "treated"
*Run regression with all obs - duplicates over the years incl.
	eststo clear
	// loop over years
	forval j=1/5{
		// regression just to get the sample
		 qui:reg outcome_learnings_`j' treatedXc_edu_pregpa7w edu_pregpa7 treated edu_pregpa13w    edu_pregpa13w2 treatedXedu_pregpa13w3 treatedXedu_pregpa13w2 edu_pregpa13w3 treatedXedu_pregpa13w  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		// residual variation 
		qui: reg treatedXc_edu_pregpa7w edu_pregpa7 treated edu_pregpa13w    edu_pregpa13w2 treatedXedu_pregpa13w3 treatedXedu_pregpa13w2 edu_pregpa13w3 treatedXedu_pregpa13w  if e(sample), cluster(edu_gpa_group)
		predict res, residual
		qui:sum res
		local sd=r(sd)
		// main regression
		eststo: qui: reg outcome_learnings_`j' treatedXc_edu_pregpa7w edu_pregpa7 treated edu_pregpa13w    edu_pregpa13w2 treatedXedu_pregpa13w3 treatedXedu_pregpa13w2 edu_pregpa13w3 treatedXedu_pregpa13w   $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		qui: estadd scalar mysd=`sd'
		drop res
	
	/* output  table*/
	esttab using "$df\tab_DiD_dups`i'.tex",  fragment nomtitles ///
					replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
					nolines nogaps nonumbers se b(%6.3f) keep(treated treatedXc_edu_pregpa7w  edu_pregpa7) label ///
	subs("N" "\hline Observations" "r2" "R-squared"  "mysd" "SD(recoded GPA)")
}

*Regression without duplicates
sort pnr year
by pnr (year): keep if _n==1

	eststo clear
	// loop over years
	forval j=1/5{
			// regression just to get the sample
		 qui:reg outcome_learnings_`j' treatedXc_edu_pregpa7w edu_pregpa7 treated edu_pregpa13w    edu_pregpa13w2 treatedXedu_pregpa13w3 treatedXedu_pregpa13w2 edu_pregpa13w3 treatedXedu_pregpa13w  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		// residual variation 
		qui: reg treatedXc_edu_pregpa7w edu_pregpa7 treated edu_pregpa13w    edu_pregpa13w2 treatedXedu_pregpa13w3 treatedXedu_pregpa13w2 edu_pregpa13w3 treatedXedu_pregpa13w  if e(sample), cluster(edu_gpa_group)
		predict res, residual
		qui:sum res
		local sd=r(sd)
		// main regression
		eststo: qui: reg outcome_learnings_`j' treatedXc_edu_pregpa7w edu_pregpa7 treated edu_pregpa13w    edu_pregpa13w2 treatedXedu_pregpa13w3 treatedXedu_pregpa13w2 edu_pregpa13w3 treatedXedu_pregpa13w   $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		qui: estadd scalar mysd=`sd'
		drop res
	
	
	/* output  table*/
	esttab using "$df\tab_DiD_nodups`i'.tex",  fragment nomtitles ///
					replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
					nolines nogaps nonumbers se b(%6.3f) keep(treated treatedXc_edu_pregpa7w  edu_pregpa7) label ///
	subs("N" "\hline Observations" "r2" "R-squared"  "mysd" "SD(recoded GPA)")
}

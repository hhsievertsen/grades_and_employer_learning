/* 		21_iv_specificaiton
		created: 		hhs 05-07-2022
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"


// Load data
use  "$tf\graduate_data12007.dta",clear
eststo clear
// Loop over years
forval i=1/5{
	// Regression to get the sample
	qui: reg outcome_learnings_`i' edu_pregpa7w	 $cov0 $cov1 $cov2, cluster(edu_gpa_group)
	// Residual variation
	cap drop  res
	reg edu_pregpa7w 	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2 if e(sample), cluster(edu_gpa_group)
	predict res, residual
	sum res
	local sd=r(sd)
	// OLS 
	
	eststo ols`i': reg  outcome_learnings_`i' edu_gpaw 	$cov0 $cov1 $cov2       , cluster(edu_gpa_group)
	// OLS2 
	eststo ols2`i': reg  outcome_learnings_`i' edu_pregpa13w 	$cov0 $cov1 $cov2       , cluster(edu_gpa_group)
	// RF 
	eststo rf`i': reg  outcome_learnings_`i' res 	$cov0 $cov1 $cov2  edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 , cluster(edu_gpa_group)
	// first stage
	eststo fs`i': reg edu_gpaw 	$cov0 $cov1 $cov2  edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 res if outcome_learnings_`i'!=. , cluster(edu_gpa_group)
	test res=0
	estadd scalar Fstat=r(F)
	// iv
	eststo iv`i': ivregress 2sls outcome_learnings_`i' (edu_gpaw=res)   edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
	
}
// generate tables
esttab fs1 fs2 fs3 fs4 fs5 using "$df\tab_fs.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 Fstat,fmt(%4.0f %4.2f  %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(res	  ) label 
	
esttab rf1 rf2 rf3 rf4 rf5 using "$df\tab_rf.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(res	  ) label 

esttab ols1 ols2 ols3 ols4 ols5 using "$df\tab_ols.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(edu_gpaw	  ) label 

esttab ols21 ols22 ols23 ols24 ols25 using "$df\tab_ols2.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa13w	  ) label 

				
	
esttab iv1 iv2 iv3 iv4 iv5 using "$df\tab_iv.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 ,fmt(%4.0f %4.2f  %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(edu_gpaw	  ) label 



	

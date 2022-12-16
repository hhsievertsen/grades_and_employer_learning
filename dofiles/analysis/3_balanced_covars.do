/* 		3_balanced_covars.do:  does treatment predict covars
		created: 		hhs 22/2/2018
		                hhs 15/9 2018 ( added yhat)
						hhs 18/8 2020 cleaning + remove bootstrap 
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// Raw grades 
use  "$tf\graduate_data12007.dta",clear
// predicted earnings
qui: reg outcome_learnings_1  $cov0  $cov1 $cov2
predict wagehat,xb
// replace missings
replace cov_hs_gpa=. if cov_hs_gpa_m==1
replace cov_age=. if cov_age_m==1
replace cov_female=. if cov_female_m==1
replace cov_parental_income=. if cov_parental_incobserved==0
replace cov_parental_schooling_uni=. if  cov_parental_schoolingobserved==0 
replace cov_undergrad_gpa=. if cov_undergrad_gpa_m==1
// run reg 
eststo clear
foreach var in  cov_female cov_hs_gpa cov_undergrad_gpa cov_parental_income cov_parental_une cov_parental_schooling_uni wagehat {
	// regression
	eststo: reg `var' edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0, cluster(edu_gpa_group)
	// add mean of depvar
	qui: sum `var'
	estadd scalar mdv=r(mean)
}
// output 
esttab using "$df\tab_reg_balanced.tex",  keep(edu_pregpa7w) fragment ///
				replace star(* 0.1 ** 0.05 *** 0.01) label nomtitles stat(N r2 mdv,fmt(%10.0f %5.2f %5.2f)) nolines nogaps nonumbers se b(%6.3f)  ///
					subs("N" "\hline Observations" "r2" "R-squared"  "mdv" "Mean dep. var")
					

/* 		20_el_specificaiton
		created: 		hhs 04-07-2022
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"

// Load data
use  "$tf\graduate_data12007.dta",clear
// standardize 
reshape long outcome_learnings_ ,i(pnr) j(t)
drop if t==0
replace t=t-1
// balanced panel
drop if outcome_learnings_==.
bys pnr: gen c=_N
keep if c==5
// predict residual

reg edu_pregpa7w 	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 , cluster(edu_gpa_group)
predict res, residual
gen resraw=res
sum res
replace res=(res-r(mean))/r(sd)
// standardize variables
sum edu_pregpa13w
gen gpa13=(edu_pregpa13w-r(mean))/r(sd)
sum edu_pregpa7w
gen gpa7=(edu_pregpa7w-r(mean))/r(sd)
// interaction terms
gen gpa13Xt=gpa13*t
gen gpa7Xt=gpa7*t
gen resXt=res*t
gen resrawXt=resraw*t
gen edu_pregpa13wXt=edu_pregpa13w*t 
gen edu_pregpa7wXt=edu_pregpa7w*t
// labels
label var gpa7 "GPA7"
label var gpa13 "GPA13"
label var gpa7Xt "GPA7 $\times$ t"
label var gpa13Xt "GPA13 $\times$ t"
label var res "Res"
label var resXt "Res $\times$ t"
label var t "t"
label var edu_pregpa13w "GPA13 (raw)"
label var edu_pregpa7w "GPA7 (raw)"
label var edu_pregpa13wXt "GPA13 (raw) $\times$ t"
label var edu_pregpa7wXt "GPA7 (raw) $\times$ t"
label var resraw "Res (raw)"
label var resrawXt "Res (raw) $\times$ t"
// regresions (standardized)
eststo clear
eststo: reg outcome_learnings_   $cov0   gpa7  ,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   gpa13  ,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   gpa7 t gpa7Xt ,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   gpa13 t gpa13Xt ,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   gpa7 gpa13 t gpa7Xt gpa13Xt,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   gpa7 res t gpa7Xt resXt,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   gpa13 res t gpa13Xt resXt,cluster(edu_gpa_group)
esttab using "$df\tab_ELspec.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 ,fmt(%4.0f %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(gpa7 gpa13 gpa7Xt gpa13Xt res t	resXt  ) label ///
	subs("N" "\hline Observations" "r2" "R-squared" )

	
// regresions (raw)
eststo clear
eststo: reg outcome_learnings_   $cov0   edu_pregpa7w  ,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   edu_pregpa13w  ,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   edu_pregpa7w t edu_pregpa7wXt ,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   edu_pregpa13w t edu_pregpa13wXt ,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   edu_pregpa7w edu_pregpa13w t edu_pregpa7wXt edu_pregpa13wXt,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   edu_pregpa7w resraw t edu_pregpa7wXt resrawXt,cluster(edu_gpa_group)
eststo: reg outcome_learnings_   $cov0   edu_pregpa13w resraw t edu_pregpa13wXt resrawXt,cluster(edu_gpa_group)
esttab using "$df\tab_ELspec_raw.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 ,fmt(%4.0f %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w edu_pregpa13w edu_pregpa13wXt edu_pregpa7wXt resraw t	resrawXt  ) label ///
	subs("N" "\hline Observations" "r2" "R-squared" )
	
	


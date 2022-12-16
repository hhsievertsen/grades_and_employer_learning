/* 		19 Describe age
		created: 		hhs: 03/07/2022
*/

// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// Age distribtion
// Years in education
// load data
use  "$tf\graduate_data12007.dta",clear
keep pnr edu_stopdate
// merge with  educational spells
merge 1:m pnr using "$rf\kotre.dta",keep(1 3) keepusing(udd audd elev3_vfra elev3_vtil) nogen
// merge with format about type
tostring udd, replace
merge m:1 udd using "$ff\uddan_2014_udd",nogen keep(1 3)
// drop if after end
drop if elev3_vfra>edu_stopdate
drop if audd==9999
gen duration=(elev3_vtil-elev3_vfra)/365.24
collapse (sum) duration,by(pnr h1)
compress
destring h1, replace
drop if h1==.
reshape wide duration,i(pnr) j(h1) 
save "$tf\educationspelldurations.dta",replace
sum


// Labor market experience
forval i=2002/2015{
	use pnr erhver erhver79 using "$rf\Idap`i'.dta",clear
	replace erhver=0 if erhver==.
	replace erhver79=0 if erhver79==.
	replace erhver=erhver/1000
	gen labormarketexperience=erhver79+erhver
	* save
	keep pnr labormarketexperience
	gen int t=`i'
	compress
	if `i'==2002{
		save "$tf\experience.dta",replace
		}
	else{
		append using "$tf\experience.dta"
		save "$tf\experience.dta",replace
	}
}
use  "$tf\graduate_data12007.dta",clear
keep pnr edu_stopdate cov_age cov_age_m
drop if cov_age_m==1
gen t=year(edu_stopdate)
merge 1:1 pnr t using  "$tf\experience.dta",nogen keep(1 3)
merge 1:1 pnr using "$tf\educationspelldurations.dta",nogen keep(1 3)
gen age=round(cov_age)
gen durt=0
foreach d in  20 25 30 35 40 50 60 65 70{
	replace duration`d'=0 if duration`d'==.
	replace durt=durt+duration`d'
}
gen unexplained=cov_age-15.5-durt-labormarketexperience
preserve
foreach v in  unexpl durt laborm cov_age{
	mypercentile `v',p(50)
	local med_`v': disp %4.1f r(p50)
}

collapse (mean) dur* lab unexplained (count) n=cov_age,by(age)
sum n
gen s=n/r(sum)
drop if n<5
replace unexplained=durt+laborm+unexplained
replace laborm=laborm+durt

tw (bar unex age, lcolor(black) lpattern(dash) fcolor(white)) ///
   (bar labormarketexperience age, lcolor(gs8) fcolor(gs8)) ///
   (bar durt age, lcolor(black) fcolor(black)) ///
   (line s age,yaxis(2) lcolor(black) lwidth(medthick)) ///
	, graphregion(fcolor(white) lcolor(white)) ///
	plotregion(fcolor(white) lcolor(black)) ///
	xlab(24(4)56,format(%4.0f)) ylab(,format(%4.0f) angle(horizontal)) ylab(,format(%4.2f) axis(2) angle(horizontal)) ///
	xtitle("Age at graduation (years)") ytitle("Years") ytitle("Share",axis(2)) ///
	legend(order(3 "Years in education" 2 "Labor market experience" 1 "Unexplained time" ///
	4 "Share of the population (right axis)") region(lcolor(white)) pos(12)) ylab(0(10)40) ///
	text( 40 35 "Age (p50):                     `med_cov_age'y",size(small)) ///
	text( 38 35 "In education (p50):         `med_durt'y",size(small)) ///
	text( 36 35 "Labor market exp (p50): `med_laborm'y",size(small)) ///
	text( 34 35 "Unexplained time (p50): `med_unexpl'y",size(small)) 
	graph export "$df\fig_age_distribution.png",replace width(2000)


tw (bar unex age, lcolor(black) lpattern(dash) fcolor(white)) ///
   (bar labormarketexperience age, lcolor(gs8) fcolor(gs8)) ///
   (bar durt age, lcolor(black) fcolor(black)) ///
   (line s age,yaxis(2) lcolor(black) lwidth(medthick)) ///
	, graphregion(fcolor(white) lcolor(white)) ///
	plotregion(fcolor(white) lcolor(black)) ///
	xlab(24(4)56,format(%4.0f)) ylab(,format(%4.0f) angle(horizontal)) ylab(,format(%4.2f) axis(2) angle(horizontal)) ///
	xtitle("Age at graduation (years)") ytitle("Years") ytitle("Share",axis(2)) ///
	legend(order(3 "Years in education" 2 "Labor market experience" 1 "Unexplained time" ///
	4 "Share of the population (right axis)") region(lcolor(white)) pos(12))  ylab(0(10)40) ///
	text( 40 34 "Age (p50):                                `med_cov_age'y",size(vsmall)) ///
	text( 38 34 "In post comp. educ (p50):  `med_durt'y",size(vsmall)) ///
	text( 36 34 "Labor market exp (p50):          `med_laborm'y",size(vsmall)) ///
	text( 34 34 "Unexplained time (p50):          `med_unexpl'y",size(vsmall)) 
	graph export "$df\fig_age_distribution_v2.png",replace width(2000)	
	

// Regression without age outliers
// Load data
use  "$tf\graduate_data12007.dta",clear
eststo clear
gen a=cov_age if cov_age_m==0
mypercentile a ,p(90)
di r(p90)
drop if a>r(p90)
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

}
// generate table
esttab using "$df\tab_reg_age.tex",  fragment nomtitles ///
	replace star(* 0.1 ** 0.05 *** 0.01) stat(N r2 mysd,fmt(%4.0f %4.2f  %4.2f    )) ///
	nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w	  ) label ///
	subs("N" "\hline Observations" "r2" "R-squared"  "mysd" "SD(recoded GPA)")

/* 		16_gpa_grade_inflation
				edited: 		hhs 20/08/2020
*/
// load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
// Load data load data
use "$tf\gpa_level62.dta",clear
//Sample selection 
gen year=year(elev3_vtil)
gen startyear=year(elev3_vfra)
keep if startyear>=2000 & startyear<=2010
keep if year>=2002 & year<=2012
preserve
 // Collapse overall GPA
collapse (mean) gpa , by(year scale)
tw 		(connected gpa year if scale7==0,msymbol(S)  mcolor(gs2) lcolor(gs2) lwidth(medthick))  ///
		(connected gpa year if scale7==1,msymbol(T)  mcolor(gs7) lcolor(gs7) lwidth(medthick)) ///
	,  graphregion(lcolor(white) fcolor(white))   plotregion(margin(zero) lcolor(black) fcolor(white)) ///
	xlabel(#10, ///
	notick labgap(medium)) ytitle("GPA") xtitle("") ///
	xscale(noline)   yscale(noline) ///
	 xtitle("Graduation year") ///
		legend(order(1 "13 scale" 2 "7-point scale") pos(12) ring(1) rows(1) region(lcolor(white))) ///
	ylabel(6(1)10,labgap(medium) angle(horizontal) notick grid glwidth(medthick)  gmax   glcolor(gs14)   nogextend)  
	graph export "$df\fig_app_gpa_inflation_years.png",replace width(2000)


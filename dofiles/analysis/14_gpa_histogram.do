/* 		14_gpa_histogram.do
				edited: 		hhs 20/08/2020
*/
// load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
// load data
use "$tf\gpa_level62.dta",clear
// Select cohorts
gen year=year(elev3_vtil)
gen startyear=year(elev3_vfra)
keep if startyear>=2000 & startyear<=2012
keep if year>=2002 & year<=2014
// count frequencies
gen r=round(gpa,.2)
collapse (count) n=year,by(scale7 r)
bys sc: egen sum=sum(n)
gen s=n/sum
// remove small cells
drop if n<3
// generate chart
tw  (bar s r if scale7==0,fcolor(black) lcolor(white) lwidth(vthin) barwidth(0.2) ) ///
(bar s r if scale7==1,fcolor(gs8%70) lcolor(white%50) lwidth(vthin) barwidth(0.2) )  ///
	,  graphregion(lcolor(white) fcolor(white))   plotregion(margin(zero) lcolor(black) fcolor(white)) ///
	xlabel(2(1)13, ///
	notick labgap(medium)) ytitle("Fraction") xtitle("") ///
	xscale(noline)   yscale(noline) ///
	 xtitle("GPA ") ///
	legend(order(1 "13 scale" 2 "7-point scale") pos(12) ring(1) rows(1) region(lcolor(white))) ///
	ylabel(0(0.02)0.09,labgap(medium) format(%4.2f) nogrid angle(horizontal) notick  glwidth(medthick)  gmax   glcolor(gs14)   )  
	graph export "$df\fig_app_gpa_hist.png",replace width(2000)	
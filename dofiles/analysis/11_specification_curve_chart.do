/* 		create spec curve data
		created: 		hhs 17/10/2019  
		edited: 		hhs 20/08/2020
*/
// load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"

* load data
use "$tf\estimatesforechart.dta",clear
sort  beta
gen rank=_n
gen u=beta+1.96*se
gen l=beta-1.96*se
gen u64=beta+1.64*se
gen l64=beta-1.64*se
* specification 
gen controls=-0.04
gen spec2nd=-0.05
gen spec3rd=-0.06
gen spec4th=-0.07
gen lspecnpmean=-0.08
* sample
gen lectslimit35=-0.10
gen lectslimit40=-0.11
gen lectslimit45=-0.12
gen ects2009=-.14
gen ects2010=-.15
gen ects2011=-.16
set trace off
replace ectslimit40=0 if ectslimit40==.
tw   (rbar u l rank, lcolor(gs13) fcolor(gs13) lwidth(thin))  ///
	 (rbar u64 l64 rank , lcolor(gs10) fcolor(gs10) lwidth(thin))  ///
	 (scatter beta rank , msymbol(D) msize(vsmall) mcolor(black))  ///
	 	 (scatter beta rank if year2010==1& ectslimit40==1   & covars==1 & spec3rdorder==1, msymbol(D) mcolor(midblue) msize(vsmall))  ///
	 /* indicators */ ///
	 (scatter controls rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter controls rank if covars==1, msymbol(O) msize(vsmall) mcolor(black)) ///
	 (scatter spec2nd rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter spec2nd rank if spec2ndorder==1, msymbol(O) msize(vsmall) mcolor(black)) ///
	 (scatter spec3rd rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter spec3rd rank if spec3rdorder==1, msymbol(O) msize(vsmall) mcolor(black)) ///
	 (scatter spec4th rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter spec4th rank if spec4thorder==1, msymbol(O) msize(vsmall)  mcolor(black)) ///
	 (scatter lspecnpmean rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter lspecnpmean rank if specnpmean==1, msymbol(O) msize(vsmall) mcolor(black)) ///
	 (scatter lectslimit35 rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter lectslimit35 rank if ectslimit35==1, msymbol(O) msize(vsmall) mcolor(black)) ///
	 (scatter lectslimit40 rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter lectslimit40 rank if ectslimit40==1 , msymbol(O) msize(vsmall) mcolor(black)) ///
	 (scatter lectslimit45 rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter lectslimit45 rank if ectslimit45==1, msymbol(O) msize(vsmall) mcolor(black)) ///
	 (scatter ects2009 rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter ects2009 rank if year2009==1 , msymbol(O) msize(vsmall) mcolor(black)) ///
	 (scatter ects2010 rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter ects2010 rank if year2010==1 , msymbol(O) msize(vsmall)  mcolor(black)) ///
	 (scatter ects2011 rank, msymbol(O) msize(vsmall) mcolor(gs14)) ///
	 (scatter ects2011 rank if year2011==1 , msymbol(O) msize(vsmall) mcolor(black)) ///
	(scatter controls rank if  year2010==1   &  ectslimit40==1& covars==1 & spec3rdorder==1, msymbol(O) mcolor(midblue) msize(vsmall)) ///
	(scatter spec3rd rank if year2010==1   &  ectslimit40==1 & covars==1 & spec3rdorder==1, msymbol(O) mcolor(midblue) msize(vsmall)) ///
	(scatter lectslimit40 rank if  year2010==1   &  ectslimit40==1  & covars==1 & spec3rdorder==1, msymbol(O) mcolor(midblue) msize(vsmall)) ///
	(scatter ects2010 rank if  year2010==1   &  ectslimit40==1 & covars==1 & spec3rdorder==1, msymbol(O) mcolor(midblue) msize(vsmall)) ///
	, graphregion(lcolor(white) fcolor(white)) plotregion(lcolor(white) fcolor(white)) ///
	 yscale(noline) ylab(,noticks angle(horizontal) format(%4.2f) nogrid) ///
	 xscale(noline) xlab(1 " ",noticks)  xtitle(" ") ///
	 yline(0, lcolor(black))  ///
	 ylab(-0.16  " " 0 "0.00    " 0.05 "0.05    " ///
	 0.1 "0.10    "  0.15 "0.15    "  0.20 "0.20    "     0.22 "Coefficient",labsize(small)) ///
	legend(order(3 "Point-estimate" 4 "Main spec." 2 "90% CI" 1 "95% CI") region(lcolor(white)) symxsize(small) position(12) ///
	symysize(vsmall) size(vsmall) row(1) ring(0)) ytitle(" ")
	 * add labels
gr_edit .yaxis1.add_ticks -0.0385 `"Covariates"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.0485 `"2nd poly"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.0585 `"3rd poly"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.0685 `"4th poly"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.0785 `"NP Mean"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )

gr_edit .yaxis1.add_ticks -0.0985 `"<=35"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.1085 `"<=40"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.1185 `"<=45"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )

gr_edit .yaxis1.add_ticks -0.1385 `"<=2009"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.1485 `"<=2010"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.1585 `"<=2011"', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )

gr_edit .yaxis1.add_ticks -0.0295 `"Specification          "', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )
gr_edit .yaxis1.add_ticks -0.095 `"ECTS                   "', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )

gr_edit .yaxis1.add_ticks -0.13 `"Graduation          "', custom tickset(major) editstyle(tickstyle(textstyle(size(vsmall))) )

graph export "$df\fig_robustness.png", width(2000) replace
/* 		15_grading_patterns
		edited: 		hhs 20/08/2020
*/
// load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"

// load grades for graduate
use  "$tf\unused_grades.dta",clear
keep if bedoemmelsesdato<mdy(8,1,2007)
// drop if no grade
destring     OPR_KARAKTER,replace force
drop if OPR_KARAKTER==.
// define academic year
replace bedoemmelsesdato=mdy(1,31,year(bedoemmelsesdato)) if bedoemmelsesdato>=mdy(1,1,year(bedoemmelsesdato)) & bedoemmelsesdato<mdy(3,1,year(bedoemmelsesdato))
replace bedoemmelsesdato=mdy(1,31,year(bedoemmelsesdato)+1) if bedoemmelsesdato>=mdy(8,31,year(bedoemmelsesdato)) 
replace bedoemmelsesdato=mdy(7,31,year(bedoemmelsesdato)) if bedoemmelsesdato>=mdy(3,1,year(bedoemmelsesdato)) & bedoemmelsesdato<mdy(9,1,year(bedoemmelsesdato))
keep if year(bedoem)>2003
// count frequencies
collapse (count) n=used,by(OPR_KARAKTER bedoemm) fast
drop if bedoem==.
bys bedoem: egen sum=sum(n)
gen share=n/sum
drop if n<3
sort OPR_KARAKTER bedoem
by OPR_KARAKTER: gen bed=_n
gen a=bed
// shift marks
replace a=bed+9 if OPR==3
replace a=bed+9*2 if OPR==5
replace a=bed+9*3 if OPR==6
replace a=bed+9*4 if OPR==7
replace a=bed+9*5 if OPR==8
replace a=bed+9*6 if OPR==9
replace a=bed+9*7 if OPR==10
replace a=bed+9*8 if OPR==11
replace a=bed+9*9 if OPR==13
// create chart
	
tw  (bar share a  if bedoem==mdy(1,31,2004), fcolor(black) lcolor(white) lwidth(vvthin)) ///
	(bar share a  if bedoem==mdy(7,31,2004), fcolor(gs2) lcolor(white) lwidth(vvthin)) ///
	(bar share a  if bedoem==mdy(1,31,2005), fcolor(gs3) lcolor(white) lwidth(vvthin)) ///
	(bar share a  if bedoem==mdy(7,31,2005) , fcolor(gs4) lcolor(white) lwidth(vvthin)) ///
	(bar share a  if bedoem==mdy(1,31,2006), fcolor(gs6) lcolor(white) lwidth(vvthin)) ///
	(bar share a  if bedoem==mdy(7,31,2006) , fcolor(gs8) lcolor(white) lwidth(vvthin)) ///
	(bar share a  if bedoem==mdy(1,31,2007), fcolor(gs10) lcolor(white) lwidth(vvthin)) ///
	(bar share a  if bedoem==mdy(7,31,2007) , fcolor(gs12) lcolor(white) lwidth(vvthin)) ///
	,ylabel(0(0.05).26) ylabel(,noticks nogrid format(%4.2f) angle(horizontal)) ///
	xlabel(0 " " 5 "0" 14 "3" 23 "5" 32 "6" 41 "7" 50 "8" 59 "9" 68 "10" 77 "11" 86 "13" 95 " ",noticks) ///
	legend(order( 1 "Jan 2004" 8 "Jul 2007") pos(12) ring(1) region(lcolor(white))) ///
	graphregion(lcolor(white) fcolor(white)) ytitle(Fraction) ///
	plotregion(lcolor(black) fcolor(white) margin(tiny)) xtitle(Grade given) xscale(noline) yscale(noline)
	graph export "$df\fig_grading_pattern.png",replace width(2000)

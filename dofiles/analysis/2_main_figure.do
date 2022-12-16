/* 		2_main_figure.do:  create main figure showing variation in data; 
		created: 		hhs 24/2/2018 
		edited:		    hhs 14/9/2018  
						hhs 18/8/2020  
		                
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// load data
use  "$tf\graduate_data12007.dta",clear
// estimate fitted line on raw data
preserve
	reg edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 
	// yhat
	predict yhat,xb
	// keep
	keep yhat edu_pregpa13w 
	duplicates drop edu,force
	save "$tf\slope.dta",replace
restore
// collapse in GPA7 X GPA13  cells
replace edu_pregpa7w =round(edu_pregpa7w,.1)
replace edu_pregpa13w=round(edu_pregpa13w,.1)
collapse (count) n=edu_year,by(edu_pregpa7w  edu_pregpa13w) 
merge m:1 edu_pregpa13 using "$tf\slope.dta",keep(1 2 3) nogen
// Remove small cells
drop if n<3
// graph settings
#delimit ;
global gs 	"graphregion(lcolor(white) fcolor(white))   			
				    plotregion(margin(zero) lcolor(black) fcolor(white)) 	
					xlabel(6.5 " " 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 11.5   
					" ",format(%9.0f)  notick labgap(small)) 
					ytitle("Recoded GPA (7-point scale)") xscale(lcolor(black) 
					lwidth(medthick) line nofextend) yscale(lcolor(black) 
					lwidth(medthick) line nofextend) legend(off) 
					xtitle("Original GPA (13 scale)") ylabel( 2 " " "3" 4 "4" 5 "5" 6 "6" 7 "7" 
					8.5 "8.5" 10 "10" 11 "11" 12.5 " " ,format(%9.0f) labgap(small) angle
					(horizontal) notick nogrid 	gmax   glcolor(gs14)   nogextend )";
	
#delimit cr 	
// make raw plot of GPA7 against GPA13
tw (line yhat edu_pregpa13 if edu_pregpa13w<12 & edu_pregpa13w>6, sort lcolor(gs7) ) /// 
	(scatter edu_pregpa7 edu_pregpa13, mcolor(black) msymbol(x) ) ///
,  $gs  yscale(noline)  xscale(noline) ylab(1.5(2)12.5 ) xlab(6(1)12)
	graph export "$df\fig_main_scattervariation.png",replace width(2000)
	

// plot of residuals
use  "$tf\graduate_data12007.dta",clear
// Obtain residuals (now with covariates) 
reg edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 
predict res, res
// Round
replace edu_pregpa7 =round(res,.1)
collapse (count) n=cov_age, by(edu_pregpa7)
qui sum n
gen fraction=n/r(sum)
// Remove small cells
drop if n<3
// density
gen density=fraction/0.1
keep density edu_pregpa7
// generate chart
tw  (bar density edu,barwidth(0.1) fcolor(black) lcolor(white) lwidth(thin)) ///
	, 	$gs xlab(-1.5(0.5)1.5,format(%9.1f)) ylab(0(0.2)1.3,format(%9.1f)) legend(off) ///
	xtitle("Recoded GPA (residualized)") ytitle("Density") yscale(noline) xscale(noline)
	graph export "$df\fig_hist_residual.png",replace width(2000)

	
	
	
	
	
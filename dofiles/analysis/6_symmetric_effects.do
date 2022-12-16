/* 		9_asymmetri.do:  asymmetic effects
		created: 		hhs 14/9/2018  (new specs)
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// Graph settings 
#delimit ;
global gs 	"graphregion(lcolor(white) fcolor(white))   			
				    plotregion(margin(tiny)  lcolor(black) fcolor(white)) 	
									 xscale(noline) yscale(noline )  yscale(noline axis(2) )
					legend(order(1 "Distribution (left)" 3 "Linear fit (right)" 4 "Cubic natural spline (right)") 
					region(lcolor(white)) rows(1) pos(12) size(small) colgap(tiny) symxsize(medium) symysize(small)  )   ytitle(Fraction,axis(2))
					xtitle("Recoded GPA (residualized)") ylabel(,format(%9.2f) angle
					(horizontal) notick nogrid 	   glcolor(white)    )";
#delimit cr
// Loop over yaers
forval i=1/5{
    // Load data
	use  "$tf\graduate_data12007.dta",clear
	// Identify sample
	reg outcome_learnings_`i'  edu_pregpa7w	edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 	  $cov0 $cov1 $cov2 
	keep if e(sample)
	// Residualize
	reg edu_pregpa7w 		edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 				 $cov0 $cov1 $cov2 
	predict x_res,res
	reg outcome_learnings_`i' 	edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 	  $cov0 $cov1 $cov2 
	predict y_res,res
	// values for histogram
	gen res_rounded=round(x_res,.1)
	bys res_rounded: egen freq=count(x_res)
	bys res_rounded: replace freq=. if _n>1
	sum freq
	gen freqr=freq/r(sum)
	// don't show small cells
	replace freqr=. if freq<3 
	// Compute natural spline
	 mkspline _r = x_res, cubic nknots(3) 
	 reg y_res _r*
	 predict natspline, xb
	 bys res_rounded: replace natspline=. if _n>1
	// linear fit 
	reg y_res x_res
	margins, at(x_res=(-1(0.1)1))
	mat tab=r(table)
	mat yhat=tab[1,1..21]'
	mat lower=tab[5,1..21]'
	mat upper=tab[6,1..21]'
	svmat yhat, names(ols)
	svmat lower, names(ols_lower)
	svmat upper, names(ols_upper)
	gen x=_n/10-1.1 if _n<22
	// create chart
	replace freqr=.  if res_rounded>1 | res_rounded<-1
	tw (bar freqr res_rounded if res_rounded<=1 & res_rounded>=-1, yaxis(2) barwidth(0.09) fcolor(gs12) lcolor(gs8) ) ///	
			(rarea ols_u ols_l x if x<=1 & x>=-1,lwidth(none) fcolor(gs8%50) lcolor(gs8)) 			///
			(line ols1 x  if x<=1 & x>=-1,lwidth(medthick) lcolor(black)) ///
			(line natspline x_res  if x_res<=1 & x_res>=-1, sort /// 
				lwidth(medthick) lpattern(dash) lcolor(black) ), ///
				yline(0,axis(1)) ///
				xlabel(-1.2(0.2)1.2,format(%9.1f)  notick labgap(small))  ///
				$gs  ytitle("Log earnings  (residualized)") ylabel(0(0.03)0.13,format(%9.2f)  notick axis(2) angle(horizontal) )
				graph export "$df\fig_asymmetri_no_lines_y`i'.png", width(2000) replace
	
}

/* Grading simulations: generate data
   Created: 16-5-2018 hhs
   Edited: 	25-5-2018 hhs
 */
 
 

* set globals and locals
set trace off
cd "C:\Users\hs17922\Dropbox\Research\Projects\8 The signaling value of grades\Simulationer_af_funktionel_form"

* define helper programs
cap program drop givegrades
program givegrades
/* This program generates a draw of grades, given ability. The grade 
   distribution is set ot match the actual distribution. The program 
   takes 1 argument. The argument is the variable   number. */
	gen grade=rnormal(ability,25)
	sort grade
	gen a=_n/_N
	gen x`1'=.
	replace x`1'=6 if a<=0.086 & x`1'==.
	replace x`1'=7 if a<=0.234 & x`1'==.
	replace x`1'=8 if a<=0.450  & x`1'==.
	replace x`1'=9 if a<=0.695  & x`1'==.
	replace x`1'=10 if a<=0.888  & x`1'==.
	replace x`1'=11 if a<=0.985  & x`1'==.
	replace x`1'=13 if  a<=1   & x`1'==.
	drop a grade
end

cap program drop mytransform
program mytransform
/* this program recodes grades from the old scale to the new scale. The program 
   takes 1 argument. The argument is the variable number. */
	gen x`1'_transform=.
	replace x`1'_transform=2 	if   x`1'==6
	replace x`1'_transform=4 	if   x`1'==7
	replace x`1'_transform=7 	if   x`1'==8
	replace x`1'_transform=7 	if   x`1'==9
	replace x`1'_transform=10 	if   x`1'==10
	replace x`1'_transform=12 	if   x`1'==11
	replace x`1'_transform=12 	if   x`1'==13
end

cap program drop savest
program savest
/* this program saves estimates. This program takes 3 arguments. The first 
   argument is estimation specification, the second is the iteration and the 
   third is the correlation between wages and GPA, given ability. */
	preserve
		use "estimates.dta",clear
		replace tstat_`1'=abs(_b[res]/_se[res]) if iteration==`2'  & s==`3'
		save "estimates.dta",replace
	restore
end

cap program drop DGP
program DGP 
	/* this program defines and runs the DGP. The program takes two arguments,
	   the first argument is the number of observations, the second argument is 
	   the correlation between wages and GPA, given ability. */
		qui: clear
		qui: set obs `1'
		qui: gen id=_n
		* genreate ability
		qui: gen ability=runiform()*100
		* generate grades
		forval i=1/5{
			qui: givegrades `i'
			qui: mytransform `i'
		}
		* calculate gpas 
		qui: gen gpa13=(x1+x2+x3+x4+x5)/5
		qui: gen gpa7=(x1_+x2_+x3_+x4_+x5_)/5
		qui: gen y=10+0.3*ability+`2'*gpa7+rnormal()
		qui: gen lw=log(y)
end

cap program drop estdata
program estdata `1'
/* Create an empty dataset to save estimates. The program takes one argument, 
   the number of iterations */
	clear 
	set obs `1'
	gen tstat_lws_fe=.
	gen tstat_lws_p1=.
	gen tstat_lws_p2=.
	gen tstat_lws_p3=.
	gen tstat_lws_p4=.
	gen iteration=_n
	gen expand=11
	expand expand
	bys iteration: gen s=(_n-1)*5
	drop expand
	save "estimates.dta",replace
end

cap program drop myloops
program myloops
/* This program executes the DGP a number of times using various specifications, 
   and saves the results. The program takes 2 arguments. The first arguments is 
   the number of observations in each draw, and the second is the number of 
   replications. */
    estdata `2'
	* run loop
	forval j=1/`2'{	
		forval s=0(5)50{
			local cor=`s'/100
			* DGP
			DGP `1' `cor'
			* ESTIMATE
			* FE and MEDIAN SPEC
			qui: gen r=round(gpa13*10)
			bys r: egen median=median(gpa7)
			qui: gen res=gpa7-median
			qui: reg lw  res  gpa13 c.gpa13#c.gpa13 c.gpa13#c.gpa13#c.gpa13 ,robust
			qui: savest lws_fe `j' `s'
			* LINEAR
			qui: replace res=gpa7
			qui: reg lw res gpa13, robust
			qui: savest lws_p1 `j' `s'
			* QUADRATIC
			qui: reg lw res gpa13 c.gpa13#c.gpa13,robust
			qui: savest lws_p2 `j' `s'
			* CUBIC
			qui: reg lw res gpa13 c.gpa13#c.gpa13 c.gpa13#c.gpa13#c.gpa13,robust
			qui: savest lws_p3 `j'	 `s'
			* 4th
			qui: reg lw res gpa13 c.gpa13#c.gpa13 c.gpa13#c.gpa13#c.gpa13  c.gpa13#c.gpa13#c.gpa13#c.gpa13,robust
			qui: savest lws_p4 `j'	 `s'
		}
			* display COUNTER	
			if mod(`j',10)==0{
				di "`j'/`2'"
			}
	}
end


/* Show rejection rates*/
myloops 5000 10000
use "estimates.dta",clear
foreach var in  tstat_lws_fe  tstat_lws_p1  tstat_lws_p2  tstat_lws_p3  tstat_lws_p4 {
		gen `var'_reject=`var'>2
}
collapse (mean) tstat_lws_fe_reject tstat_lws_p1_reject tstat_lws_p2_reject tstat_lws_p3_reject tstat_lws_p4_reject,by(s)


replace s=s/100
tw 	(connected tstat_lws_fe_reject s,lcolor(black) 	lwidth(medthick) 	msymbol(d)  mcolor(black)) ///
	(connected tstat_lws_p1_reject s,lcolor(gs3) 	lwidth(medthick)	msymbol(s)  mcolor(gs3)) ///
	(connected tstat_lws_p2_reject s,lcolor(gs6) 	lwidth(medthick)	msymbol(x)  mcolor(gs6) msize(large)) ///
	(connected tstat_lws_p3_reject s,lcolor(gs9) 	lwidth(medthick)	msymbol(t)  mcolor(gs9)) ///
	(connected tstat_lws_p4_reject s,lcolor(gs12) 	lwidth(medthick)	msymbol(sh) mcolor(gs12)) ///
	,legend(order(1 "Median" 2 "1st" 3 "2nd" 4 "3rd" 5 "4th") ///
	region(lcolor(white)) rows(1)) xtitle(gamma) ytitle("Rejection rate")    ///
	graphregion(lcolor(white) fcolor(white)) ///
	plotregion(lcolor(black) fcolor(white))
	graph export "fig_sim_rejection_rate.pdf",replace
	
	
	
	
	
	
/* Show simulation */
DGP 5000 0
tw (scatter gpa7 gpa13,msymbol(x) mcolor(black)) ///
	,xtitle(GPA13)  ytitle(GPA7)    ///
	graphregion(lcolor(white) fcolor(white)) ///
	plotregion(lcolor(black) fcolor(white)) ///
	xlabel(6(1)13)  ylabel(2(2)12) 
	graph export "fig_sim_illustration.pdf",replace
	



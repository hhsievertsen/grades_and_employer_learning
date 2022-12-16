/* 		8_income_spells
		created: 		hhs 12/6/2020
	    edited: 		hhs 18/8/2020
*/
// load globals
do "K:\workdata\706831\grading\do_files/globals.do"
// Chart setings
#delimit ;
global gs 	"graphregion(lcolor(white) fcolor(white))   			
				    plotregion(margin(tiny) lcolor(black) fcolor(white)) 	
					ytitle("Coefficient") xscale(lcolor(black) 
					lwidth(medthick) line nofextend) yscale(lcolor(black) 
					lwidth(medthick) line nofextend) legend(off)   ylab(,noticks nogrid format(%9.2f) labgap(small) angle
					(horizontal)) yscale(noline) xscale(noline)
					xtitle("Quarters after graduation") xlabel(0 (2)13,format(%9.0f) labgap(small) angle
					(horizontal) notick nogrid 	gmax   glcolor(gs14)   nogextend )";
	
#delimit cr 

// load data
use  "$tf\graduate_data12007.dta",clear
// keep what we need
keep pnr edu_pregpa7w	 edu_pregpa13w edu_ku	  cov_parental_uneobserved cov_age cov_nonwestern cov_female  cov_parental_incobserved cov_parental_income cov_parental_uneobserved cov_parental_une cov_parental_schoolingobserved cov_parental_schooling_uni cov_female_m cov_nonwestern_m cov_age_m cov_hs_gpa cov_hs_gpa_m edu_education edu_startdate edu_stopdate outcome_learnings_1 outcome_learnings_2  edu_gpa_group edu_pregpa13w2 edu_pregpa13w3 edu_enrolyear  edu_gpa_group
// merge with monthly earnings
merge 1:m pnr using "$tf\monthly_earningspanel.dta",nogen keep(1 3) keepusing(monthly_income  firmid ym) 
/* make wide */
gen graduation_month=ym(year(edu_stopdate),month(edu_stopdate))
replace monthly_income=0 if monthly_income==.
forval i=1/36{
	gen earnings_month`i'=monthly_income if graduation_month+`i'==ym
	gen firmid_month`i'=firmid if graduation_month+`i'==ym
}
// Collapse
fcollapse (firstnm) edu_pregpa7w	 edu_pregpa13w edu_ku	  cov_parental_uneobserved cov_age cov_nonwestern cov_female  cov_parental_incobserved cov_parental_income  cov_parental_une cov_parental_schoolingobserved cov_parental_schooling_uni cov_female_m cov_nonwestern_m cov_age_m cov_hs_gpa cov_hs_gpa_m edu_education edu_startdate edu_stopdate firmid_month* earnings_month* outcome_learnings_* edu_gpa_group edu_enrolyear  edu_pregpa13w2 edu_pregpa13w3 graduation_month,by(pnr)

// quarterly earnings
gen lq1=log(earnings_month1+earnings_month2+earnings_month3) if year(edu_stopdate)<2011
gen lq2=log(earnings_month4+earnings_month5+earnings_month6) if year(edu_stopdate)<2011
gen lq3=log(earnings_month7+earnings_month8+earnings_month9) if year(edu_stopdate)<2011
gen lq4=log(earnings_month10+earnings_month11+earnings_month12) if year(edu_stopdate)<2011
gen lq5=log(earnings_month13+earnings_month14+earnings_month15) if year(edu_stopdate)<2010
gen lq6=log(earnings_month16+earnings_month17+earnings_month18) if year(edu_stopdate)<2010
gen lq7=log(earnings_month19+earnings_month20+earnings_month21) if year(edu_stopdate)<2010
gen lq8=log(earnings_month22+earnings_month23+earnings_month24) if year(edu_stopdate)<2010
gen lq9=log(earnings_month25+earnings_month26+earnings_month27) if year(edu_stopdate)<2009
gen lq10=log(earnings_month28+earnings_month29+earnings_month30) if year(edu_stopdate)<2009
gen lq11=log(earnings_month31+earnings_month32+earnings_month33) if year(edu_stopdate)<2009 
gen lq12=log(earnings_month34+earnings_month35+earnings_month36) if year(edu_stopdate)<2009
// employer change 
g firstfirm=.
gen secondfirm=.
gen firstmonthfirstfirm=.
gen lasttmonthfirstfirm=.
gen firstmonthsecondfirm=.
gen employer_change=0
forval i=1/36{
	local j=`i'+1
	//First firm
	replace firstmonthfirstfirm=`i' if firmid_month`i'!=.  & firstfirm==.
	replace firstfirm=firmid_month`i' if firmid_month`i'!=.  & firstfirm==.
	cap replace lasttmonthfirstfirm=`i' if firmid_month`i'==firstfirm  & firstfirm!=. &   firmid_month`j'!=firstfirm & lasttmonthfirstfirm==. 
	//Second Firm
	replace firstmonthsecondfirm=`i' if firmid_month`i'!=.  & firstfirm!=. & secondfirm==.
	replace secondfirm=firmid_month`i' if firmid_month`i'!=. & firmid_month`i'!=firstfirm 
	
}
replace firstmonthsecondfirm=. if firstmonthsecondfirm==36
// save data
save "$tf\monthlydata.dta",replace
// Chart first employer
	use "$tf\monthlydata.dta",clear
	// counts
	collapse (count) n=cov_female,by(firstmonthfirstfirm)
	sum n
	gen share=n/r(sum)
	// small cells
	replace share=. if n<3
	drop if firstmonthfirstfirm==.
	// chart
	tw (bar share firstmonth, fcolor(black) lcolor(white) lwidth(vthin) ), ///
	  $gs ytitle(Fraction) ylab(0(0.1)0.65) xtitle("Months after graduation") xlab(0(2)36) 
		graph export "$df\fig_start_first_job.png",replace width(2000)
// Chart started second employer
	use "$tf\monthlydata.dta",clear
	// counts
	collapse (count) n=cov_female,by(firstmonthsecondfirm)
	sum n
	gen share=n/r(sum)
	// small cells
	replace share=. if n<3
	drop if firstmonthsecondfirm==.
	// chart
	tw (bar share firstmonth, fcolor(black) lcolor(white) lwidth(vthin) ), ///
	  $gs ytitle(Fraction) ylab(0(0.02)0.1) xtitle("Months after graduation") xlab(0(2)36) 
		graph export "$df\fig_start_second_job.png",replace width(2000)
// Chart graduated 
	use "$tf\monthlydata.dta",clear
	gen date=ym(year(edu_stopdate),month(edu_stopdate))
	// counts
	collapse (count) n=cov_female,by(date)
	sum n
	gen share=n/r(sum)
	// small cells
	replace share=. if n<3
	drop if date==.
	format date %tm
	// chart
	tw (bar share date, fcolor(black) lcolor(white) lwidth(vthin) ), ///
	  $gs ytitle(Fraction) ylab(0(0.02)0.1) xtitle("Months after graduation") xlab(#7,format(%tm)) 
		graph export "$df\fig_graduated.png",replace width(2000)
		

// Estimate earnings effects  by quarter 
// Dataset for storing estimates
clear
set obs 36
gen quarter=_n
gen beta=.
gen se=.
save "$tf\monthlyceof.dta",replace
// Load data
use "$tf\monthlydata.dta",clear
// Loop over quarters
forval i=1/12{
   qui: reg lq`i' $cov0 $cov1 $cov2 edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3   , cluster(edu_gpa_group)
   preserve
	use "$tf\monthlyceof.dta", clear
		replace beta=_b[edu_pregpa7w] if quarter==`i'
		replace se=_se[edu_pregpa7w] if quarter==`i'
	save "$tf\monthlyceof.dta",replace
   restore
}
// Create chart	
use "$tf\monthlyceof.dta", clear
drop if beta==.
gen u=beta+1.96*se
gen l=beta-1.96*se
tw (rspike u l quarter, lcolo(black) ) ///
 (connected beta quarter, lcolor(black) mcolor(black) msymbol(D)) ///
  , $gs yline(0)
  

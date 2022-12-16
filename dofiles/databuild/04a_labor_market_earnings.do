/*		04_labor_market_earnings.do: create annual earnings files
		created: 		hhs 24/2/2018 
		edited:			hhs 18/6/2020, cleaning
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
forval i=2002/2015{
	use "$rf\RAS`i'.dta"
	replace bredt_loenbeloeb=loenblb if `i'<2008
	keep pnr bredt_loenbeloeb
	* collapse to one obs
	sort pnr
	by pnr: egen earnings=sum(bredt)
	by pnr: keep if _n==1
	drop bredt
	* convert earns
	replace earnings=earnings*(100/76.2) if `i'==2000 /* Adjusted uing CPI */
	replace earnings=earnings*(100/78.0) if `i'==2001
	replace earnings=earnings*(100/79.9) if `i'==2002
	replace earnings=earnings*(100/81.6) if `i'==2003
	replace earnings=earnings*(100/82.5) if `i'==2004
	replace earnings=earnings*(100/84.0) if `i'==2005
	replace earnings=earnings*(100/85.6) if `i'==2006
	replace earnings=earnings*(100/87.1) if `i'==2007
	replace earnings=earnings*(100/90.1) if `i'==2008
	replace earnings=earnings*(100/91.2) if `i'==2009
	replace earnings=earnings*(100/93.3) if `i'==2010
	replace earnings=earnings*(100/95.9) if `i'==2011
	replace earnings=earnings*(100/98.2) if `i'==2012
	replace earnings=earnings*(100/99.0) if `i'==2013
	replace earnings=earnings*(100/99.6) if `i'==2014
	replace earnings=earnings*.00013 /* 1.000 EURO */
	* save
	keep pnr earnings
	gen learnings=log(earnings)
	compress
	save "$tf\earnings`i'.dta",replace
}
* append
use  "$tf\earnings2015.dta",clear
gen int year =2015
forval i=2002/2014{
	append using "$tf\earnings`i'.dta"
	replace year=`i' if year==.
}
/* save long*/
preserve
	bys pnr year: gen n=_n
	drop if n>1
	drop n
	compress
	save "$tf\earningslong.dta",replace
restore
/* generate wide */
bys pnr: keep if _n==1
reshape wide earnings learnings,i(pnr) j(year)
save "$tf\earnings.dta",replace

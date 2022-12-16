/*		06_labor_market_dispincome.do: creates data file labor market variables; 
		created: 		hhs 24/2/2018 
		edited:			hhs 16/3/2018 (replace bredt_loeblelob if missing)
						hhs 16/4/2018 (cleaning)
						hhs 27/4/2018 (changed from ras to ind)
						hhs 23/6/2020 (cleaning)
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
/* Loop over years to get income */
	forval i=2002/2013{
		use "$rf\ind`i'.dta"
		rename dispon_ny dispincome
		keep pnr  atpsaml dispincome brutto		
		sort pnr
		by pnr : keep if _n==1
		* loen
		rename brutto wageincome
		* convert dispincome to 2015 values in thousand Euros, using CPI from DST
		foreach v in dispincome wageincome{		
		replace `v'=`v'*(100/76.2) if `i'==2000
		replace `v'=`v'*(100/78.0) if `i'==2001
		replace `v'=`v'*(100/79.9) if `i'==2002
		replace `v'=`v'*(100/81.6) if `i'==2003
		replace `v'=`v'*(100/82.5) if `i'==2004
		replace `v'=`v'*(100/84.0) if `i'==2005
		replace `v'=`v'*(100/85.6) if `i'==2006
		replace `v'=`v'*(100/87.1) if `i'==2007
		replace `v'=`v'*(100/90.1) if `i'==2008
		replace `v'=`v'*(100/91.2) if `i'==2009
		replace `v'=`v'*(100/93.3) if `i'==2010
		replace `v'=`v'*(100/95.9) if `i'==2011
		replace `v'=`v'*(100/98.2) if `i'==2012
		replace `v'=`v'*(100/99.0) if `i'==2013
		replace `v'=`v'*(100/99.6) if `i'==2014
		replace `v'=`v'*.00013 /* 1.000 EURO */
		}
		* save
		keep pnr dispincome wageincome
		gen ldispincome=log(dispincome)
		gen lwageincome=log(wageincome)
		compress
		save "$tf\dispincome`i'.dta",replace
	}
/* append to one dataset */
	use  "$tf\dispincome2013.dta",clear
	gen int year =2013
	forval i=2002/2012{
		append using "$tf\dispincome`i'.dta"
		replace year=`i' if year==.
	}
/* save long format*/
	sort pnr year
	by pnr year: keep if _n==1
	compress
	save "$tf\dispincomelong.dta",replace
/* save wide format*/
	reshape wide  ldispincome dispincome lwageincome wageincome,i(pnr) j(year)
	sort pnr
	by pnr : keep if _n==1
	save "$tf\dispincome.dta",replace

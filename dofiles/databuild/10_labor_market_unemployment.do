/*		10_labor_market_unemployment.do:  unemployment
		created: 		hhs 05/09/2018 
		edited:		    hhs 13/09/2018 
						hhs 03/07/2020 cleaning
*/

* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"

* run loop
forval i=2000/2013{
	use "$rf\idap`i'.dta"
	keep pnr arledgr pstill 
	gen selfemployed=inlist(pstill,"01","02","03","04")
	replace selfemployed=1 if inlist(pstill,"05","11","12","13","14","19","20")
	gen unemployment=arledgr/1000
	gen ever_unemployed=unemployment>0
	keep pnr ever unem self
	* save
	compress
	sort pnr
	by pnr: keep if _n==1
	save "$tf\unempl`i'.dta",replace
}
* append
use  "$tf\unempl2013.dta",clear
gen int year =2013
forval i=2000/2012{
	append using "$tf\unempl`i'.dta"
	replace year=`i' if year==.
}
save "$tf\unempl.dta",replace

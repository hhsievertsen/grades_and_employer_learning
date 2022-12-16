/*		09_labor_market_jobchanges_and_sector.do: job changes, sektor etc.
		created: 		hhs 05/09/2018 
		edited:		    hhs 13/09/2018 
						hhs 03/07/2020 cleaning
*/

* load globals
		do  "K:\Workdata\706831\grading\do_files/globals.do"
* load ras data for every year
forval i=2000/2015{
	use "$rf\ras`i'.dta",clear
	keep pnr cvrnr arb_sektorkode bredt* disco* loenblb arb_nr arbgnr arbnr db   disco_ras_kode
	* earnings
	gen earnings=bredt_loenbeloeb
	replace earnings=loenblb if earnings==.
	drop bredt* loen*
	drop if earnings==. | earnings==0
	* disco
	rename disco_ras_kode occupation
	* find total income
	sort pnr earnings
	by pnr: egen totalearnings=sum(earnings)
	* find most important spell
	by pnr: keep if _n==_N
	save "$tf\ras`i'.dta",replace
}
* create panels
use "$tf\ras2000.dta",clear
gen int year=2000
forval i=2001/2015{
	append using "$tf\ras`i'.dta",
	replace year=`i' if year==.
}
sort pnr year 
* jobchanges
keep if year>2007
gen jobchange=1 
order pnr year jobchange arbnr cvrnr
*missing if first /* set missing to 99 to distinguish between not observed and missing */
by pnr: replace jobchange=99 if _n==1
* same employer both years based on cvrnr
replace jobchange=0 if cvrnr==cvrnr[_n-1] & pnr==pnr[_n-1] & year==year[_n-1]+1 & cvrnr!=""
* same employer both years based on arbnr
replace jobchange=0 if arbnr==arbnr[_n-1] & pnr==pnr[_n-1] & year==year[_n-1]+1 & arbnr!=""
* missing cvrnr or arbnr
replace jobchange=99 if (arbnr=="" | arbnr[_n-1]=="") &  (cvrnr=="" | cvrnr[_n-1]=="") & pnr==pnr[_n-1] & year==year[_n-1]+1
* sector 
gen public_sector=inlist(arb_sektorkode,71,72,74,75,76,77,79)
replace public_sector=99 if arb_sektorkode==.
* keep what we need and save
destring occupation, replace force
keep pnr year public_sector jobchange occupation
compress
save "$tf\raspanel.dta",replace











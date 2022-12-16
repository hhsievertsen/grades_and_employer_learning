/*		07_labor_market_pre_public_share.do: calculates shares hired in public sector
		created: 		ath 27/11/2018 
		edited: 		hhs 25/06/2020, cleaning
	
*/
* load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
/********************** Identify Sector *****************************************/
forval i=2000/2007{
	use "$rf\ras`i'.dta",clear
	keep pnr sektor arb_sektorkode bredt* disco* loenblb arb_nr arbgnr arbnr db   disco_ras_kode
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
	keep pnr sektor
	save "$tf\sektor`i'.dta",replace
}
* create panels
use "$tf\sektor2000.dta",clear
gen int year=2000
forval i=2001/2007{
	append using "$tf\sektor`i'.dta",
	replace year=`i' if year==.
}
sort pnr year 
* sektor 
destring sektor, replace
gen public_sector=inlist(sektor,2,3,4)
replace public_sector=99 if sektor==.
tab public_sector
* keep what we need and save
keep pnr year public_sector
compress
save "$tf\sektor.dta",replace

/********************** Identify degrees *****************************************/
use "$rf\kotre.dta",clear
* keep KU and AU
keep if inlist(instnr,751422,751431, 101455,101441,101443,101535,147410,657410,751423,101440) 
gen ku=inlist(instnr,101455,101443, 101443,101441,101440)
* keep university degree
tostring audd , replace
replace audd="0"+substr(audd,1,3) if strlen(audd)==3 
replace audd="00"+substr(audd,1,2) if strlen(audd)==2
replace audd="000"+substr(audd,1,1) if strlen(audd)==1
replace audd="" if audd=="000."
merge m:1 audd using "$ff\uddan_2014_audd",nogen keep(1 3)
* get degrees
keep if inlist(h1,"60","65")
encode U1TEKST,gen(education)
destring audd,replace
preserve
	keep audd education
	duplicates drop audd,force
	save "$tf\mappingdata.dta",replace
restore
replace audd=0 if audd==9999
* remove ba
drop if inlist(udel,0,61)
* collapse 
collapse (max) elev3_vtil   (min)  elev3_vfra , by(pnr education  ) fast
* keep years
gen year=year(elev3_vtil)
keep if year>=2002 & year<=2006
sort pnr elev3_vtil
* keep the last
by pnr: keep if _n==_N
/********************** MERGE degrees and sector *****************************************/
* merge with sector data
keep pnr year education
gen helper=year
replace year=helper+1
merge 1:1 pnr year using "$tf\sektor.dta", keep(1 3) nogen
replace year=helper
* keep what we need
keep pnr education public_sector  year 
compress
save "$tf\sektor_sharedata.dta",replace

/* calculate share in public*/ 
use "$tf\sektor_sharedata.dta",replace
drop if public_sector==99
collapse (mean)  public_share=public_sector ///
		 (count) n_public_share=public_sector,by(education)
keep if n_p>10
sum public_share, detail
gen byte edu_high_public_share=public_share>r(p50)
merge 1:m education using "$tf\mappingdata.dta",keep(3) nogen
keep audd edu_high_public_share public_share
rename (audd public_share) (edu_audd  pre_public_share)
compress
save "$tf\edusectorshare.dta",replace


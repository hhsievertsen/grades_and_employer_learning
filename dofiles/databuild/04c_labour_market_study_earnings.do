/* 		Calculate earnings while studying
		created: 		ath 11/01/2019 
		edited: 		hhs 15/08/2020 added bib skolen
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
* load kotre
use "$rf\kotre.dta",clear
* keep ku
keep if inlist(instnr,751422,751431, 101455,101441,101443,101535,147410,657410,751423) 
gen ku=inlist(instnr,101455,101443, 101443,101441,101440)


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
	keep audd education ku
	duplicates drop audd,force
	save "$tf\map.dta",replace
restore
replace audd=0 if audd==9999
* remove ba
drop if inlist(udel,0,61)
* collapse 
collapse (max) elev3_vtil   (min)  elev3_vfra , by(pnr education ku)
* keep years
gen year=year(elev3_vtil)
keep if year>=2002 & year<=2006
sort pnr elev3_vtil
* keep the last
by pnr: keep if _n==_N
* merge with earnings
keep pnr year education ku
*year before graduating
gen helper=year
replace year=helper-1
merge 1:1 pnr year using "$tf\earningslong.dta", keep(1 3) nogen
merge 1:1 pnr year using "$tf\hwlong.dta", keep(1 3) nogen
drop learnings
replace year=helper
* keep what we need
keep pnr education  earn* year hw ku
compress
save "$tf\wage_study.dta",replace

/* calculate average wages */ 
use "$tf\wage_study.dta",replace
replace earnings=0 if earnings==.
collapse (mean)  mean_earnings=earnings ///
		 (count) n_mean_earnings=earnings,by(ku education)
keep if n_mean_e>10
sum mean_earnings, detail
gen byte edu_high_earnings_study=mean_earnings>r(p50)
merge 1:m ku education using "$tf\map.dta",keep(3) nogen
keep audd ku edu_high_earnings_study mean_earnings
rename (ku audd mean_earnings) (edu_ku edu_audd  pre_mean_earnings)
compress
save "$tf\edu_study_earnings.dta",replace

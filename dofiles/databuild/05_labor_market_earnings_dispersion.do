/* 		05_labor_market_earnings_dispersion.do: calculate dispersion in earnings
		created: 		hhs 13/9/2018 
		edited: 		hhs	23/6/2020 (added biblioteksskolen)
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
* load student data
use "$rf\kotre.dta",clear
* keep ku and AU only
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
* save data for mapping (later use)
preserve
	keep audd education
	duplicates drop audd,force
	save "$tf\mappingdata.dta",replace
restore
* not completed
replace audd=0 if audd==9999
* remove undergrad degrees
drop if inlist(udel,0,61)
* collapse 
collapse (max) elev3_vtil   (min)  elev3_vfra , by(pnr education  )
* keep years
gen year=year(elev3_vtil)
keep if year>=2002 & year<=2006
sort pnr elev3_vtil
* keep the last observation by individual
by pnr: keep if _n==_N
* merge with earnings
keep pnr year education
gen helper=year
* earnings calendar year after
replace year=helper+1
merge 1:1 pnr year using "$tf\earningslong.dta", keep(1 3) nogen
merge 1:1 pnr year using "$tf\hwlong.dta", keep(1 3) nogen
drop learnings
replace year=helper
* keep what we need
keep pnr education  earn* year hw
compress
save "$tf\wage_dispersiondata.dta",replace

/* calculate wage dispersion */ 
use "$tf\wage_dispersiondata.dta",replace
drop if earnings==0
collapse (p10) p10_earnings=earnings p10_hw=hw  ///
		 (p50) p50_earnings=earnings p50_hw=hw  ///
		 (p99) p90_earnings=earnings p90_hw=hw  ///
		 (sd)  sd_earnings=earnings sd_hw=hw ///
		  (mean)  mean_earnings=earnings mean_hw=hw ///
		 (count) n_hw=hw n_earnings=earnings,by(education) fast
keep if n_e>10 /*at least 10 obs */
gen edu_ratio=p90_e/p50_e
sum edu_ratio,d
gen byte edu_high_wage_dispersion=edu_ratio>r(p50) & edu_ratio!=.
merge 1:m education using "$tf\mappingdata.dta",keep(3) nogen
keep audd edu_high_wage_dispersion edu_ratio
rename audd edu_audd
compress
save "$tf\earningsdispersion.dta",replace

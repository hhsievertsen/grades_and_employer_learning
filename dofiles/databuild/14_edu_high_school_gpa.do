/*		16_edu_high_school_gpa.do: creates High school GPA data; 
		created: 		hhs 24/2/2018 
		edited:			hhs 18/4/2018 (cleaning)
						ath 12/9/2018 (adding IB, 2-årig HHX and Studenterkursus)
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
* load data
	use "$rf\udg.dta",clear
* keep high school
	keep if inlist(audd,1145,1146,1190,1199,1539,5080,5090,1893,3324,1652)
* keep latest 
	bys pnr: egen m=max(karakter_udd_vtil)
	keep if karakter_udd_vtil==m
* create GPA
	gen cov_gpa=karakter_udd/10
* standardize
	gen y=year(karakter_udd_vtil)
	bys skala audd y:egen mean=mean(cov_gpa)
	bys skala audd y:egen sd=sd(cov_gpa)
	replace cov_gpa=(cov_gpa-mean)/sd
	*save
	sort pnr
	by pnr: keep  if _n==1
	keep pnr cov_gpa
	compress
	save "$tf\gpa.dta",replace

	
/* Specific grades */
	use "$rf\udgk.dta",clear
/*  What we need */ 
	keep if skala=="13-skala"
	keep pnr testtype karakter bevisaar udd 
/* Keep if written exam */ 
	keep if testtype=="Eksamen skriftlig"
/* Calculate GPA */ 
	destring bevisaar, replace
	collapse (mean) gpa_written=karakter (max) bevisaar ,by(pnr udd) 
/* Keep last */ 
	sort pnr bevisaar
	by pnr: keep if _n==_N
/* Save */
	sort bevisaar udd
	by bevisaar udd: egen mean=mean(gpa)
	by bevisaar udd: egen sd=sd(gpa)
	gen cov_hs_gpawritten=(gpa-mean)/sd
	keep pnr cov_
	compress
	save "$tf\hs_written.dta",replace

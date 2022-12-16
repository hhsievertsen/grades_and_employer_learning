/*		03_covars_parents.do: creates data file containing covariates for parentes; 
		created: 		hhs 24/2/2018 
		edited:			hhs 16/4/2018 (cleaning)
						hhs 17/6/2020, cleaning
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
/* Loop over bef to get age */
	forval i=2000/2012{
		* load bef
		use "$rf\bef`i'.dta",clear
		rename foed_dag date_of_birth
		keep pnr date_of_birth
		bys pnr: keep if _n==1 /* drop duplicates */
		save "$tf\par_age_y`i'.dta",replace
	}
/* Loop over ind to get disp. income and covert to thousands using the CPI from DST (2015 level) */
	forval i=2000/2012{
		* load ind
		use "$rf\ind`i'.dta",clear
		gen income=.
		replace income=dispon_ny*(100/76.2) if `i'==2000 
		replace income=dispon_ny*(100/78.0) if `i'==2001
		replace income=dispon_ny*(100/79.9) if `i'==2002
		replace income=dispon_ny*(100/81.6) if `i'==2003
		replace income=dispon_ny*(100/82.5) if `i'==2004
		replace income=dispon_ny*(100/84.0) if `i'==2005
		replace income=dispon_ny*(100/85.6) if `i'==2006
		replace income=dispon_ny*(100/87.1) if `i'==2007
		replace income=dispon_ny*(100/90.1) if `i'==2008
		replace income=dispon_ny*(100/91.2) if `i'==2009
		replace income=dispon_ny*(100/93.3) if `i'==2010
		replace income=dispon_ny*(100/95.9) if `i'==2011
		replace income=dispon_ny*(100/98.2) if `i'==2012
		replace income=dispon_ny*(100/99.0) if `i'==2013
		replace income=dispon_ny*(100/99.6) if `i'==2014
		replace income=income*.00013 /* 1.000 EURO */
		keep pnr  income
		bys pnr: keep if _n==1 /* drop duplicates */
		save "$tf\par_inc_y`i'.dta",replace
	}
/* Loop over ida to get unemployment*/
	forval i=2000/2012{
		* load ida
		use "$rf\idap`i'.dta",clear
		gen une=arledgr/1000
		keep pnr une
		bys pnr: keep if _n==1 /* drop duplicates */	
		save "$tf\par_une_y`i'.dta",replace
	}
/* Loop over udda to get education*/
	forval i=2000/2012{
		* load ida
		use "$rf\udda`i'.dta",clear
		gen audd=hfaudd
		tostring audd,replace
		replace audd="000"+substr(audd,1,1) if strlen(audd)==1
		replace audd="00"+substr(audd,1,2) if strlen(audd)==2
		replace audd="0"+substr(audd,1,3) if strlen(audd)==3
		merge m:1 audd using "$ff\uddan_2014_audd",nogen keep(1 3)
		gen schooling_uni=inlist(h1,"65"."70")
		keep pnr hfpria schooling_uni
		destring hfpria,replace
		gen schooling=hfpria/12
		keep pnr schooling schooling_uni
		bys pnr: keep if _n==1 /* drop duplicates */
		save "$tf\par_edu_y`i'.dta",replace
	}
/* Use bef to get child parent link */
	forval i=2000/2012{
		use "$rf\bef`i'.dta",clear
		keep pnr mor_id far_id
		bys pnr: keep if _n==1 /* drop duplicates */
		save "$tf\link_y`i'.dta",replace
	}
/* Merge to one dataset*/
	forval i=2000/2012{
		use "$tf\link_y`i'.dta",clear
		rename pnr id
		* mother
		rename mor_id pnr
		destring pnr,replace
		merge m:1 pnr using "$tf\par_age_y`i'.dta",nogen
		merge m:1 pnr using "$tf\par_inc_y`i'.dta",nogen
		merge m:1 pnr using "$tf\par_une_y`i'.dta",nogen
		merge m:1 pnr using "$tf\par_edu_y`i'.dta",nogen
		foreach var in date_of_birth income une schooling schooling_uni{
			replace `var'=. if missing(pnr)
			rename `var' mother_`var'
		}
		drop pnr
		* father
		rename far_id pnr
		destring pnr,replace
		merge m:1 pnr using "$tf\par_age_y`i'.dta",nogen
		merge m:1 pnr using "$tf\par_inc_y`i'.dta",nogen
		merge m:1 pnr using "$tf\par_une_y`i'.dta",nogen
		merge m:1 pnr using "$tf\par_edu_y`i'.dta",nogen
		foreach var in date_of_birth income une schooling schooling_uni{
			replace `var'=. if missing(pnr)
			rename `var' father_`var'	
		}
		drop pnr
		rename id pnr
		bys pnr: keep if _n==1 /* drop duplicates */
		compress
		save "$tf\par_cov_y`i'.dta",replace
	}

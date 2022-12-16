/*		02_covars_focal_individual.do: creates data file containing covariates for focal individual; 
		created: 		hhs 24/2/2018 
		edited:			hhs 16/4/2018 (cleaning)
		edited:			hhs 16/6/2020 (cleaning)
*/
* load globals
	do "K:\Workdata\706831\grading\do_files/globals.do"
* loop over years
	forval i=2000/2012{
		* load bef
		use "$rf\bef`i'.dta",clear
		* gender
		gen cov_female=koen==2
		* date of birth
		rename foed_dag cov_date_of_birth
		* origin
		rename opr_land land
		merge m:1 land using "$ff\grp_lande_vest_ej",nogen keep(1 3)
		gen cov_nonwestern= ie_type!=1 & VEST_EJ==3
		* keep what we need
		keep pnr cov*
		* save 
		compress
		save "$tf\basic_covariates_y`i'.dta",replace
	}
* append to one
	forval i=2000/2011{
		append using "$tf\basic_covariates_y`i'.dta",
		}
		
*save 
	bys pnr: keep if _n==1
	compress
	save "$tf\basic_covariates.dta",replace 

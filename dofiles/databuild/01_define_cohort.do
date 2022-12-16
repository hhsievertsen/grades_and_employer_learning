/* 		1_cohort.do: creates data file containing cohort (including start and stop dates etc); 
		created: 		hhs 24/2/2018 
		edited:		    hhs 23/3/2018 (initial placebo cohort)
						hhs 16/4/2018 (added more cohorts)
						ath 12/9/2018 (added more instnr)
						hhs 12/6/2020 (added more instnr)
*/
* load globals
	do "K:\Workdata\706831\grading\do_files/globals.do"
* load elevregistret
	use "$rf\kotre.dta",clear
* keep university enrolees from Aarhus and Copenhagen
	tostring udd, replace
	* merge with formats
	merge m:1 udd using "$ff\uddan_2014_udd",nogen keep(1 3)
	keep if inlist(h1,"60","65")
	* condition on institution
	keep if inlist(instnr,751422,751431, 101455,101441,101443,101535,147410,657410,751423,101440) 
	/* 751431: AU 
	   101455:  KU 
	   751422: AU Business 
	   101441: Tandlægeskolen 
	   101443: Det farmaceutiske fakultet 
	   101535: DPU Aarhus Uni i KBH 
	   147410: Det Natur og Biovidenskabelige fakultet 
	   657410: AU i Herning 
	   751423: AU tandlæge 
	   101440: Biblioteksskolen 
	   */

	* change end date for students who have status of being active
	replace elev3_vtil=mdy(12,31,2016) if afg_art=="4"
* define main cohort
	gen treat_treated=0
	replace treat_treated=1 if elev3_vfra<mdy(8,1,2007) & elev3_vtil>mdy(8,1,2007)
	
* define placebocohorts
	gen treat_placebo=0
	forval i=2001/2006{
		gen treat_placebo`i'=elev3_vfra<mdy(8,1,`i') & elev3_vtil>mdy(8,1,`i')
		replace  treat_placebo=1 if  elev3_vfra<mdy(8,1,`i') & elev3_vtil>mdy(8,1,`i')
	}
* education labels
	encode text,gen(edu_education)
	encode M1TEKST,gen(edu_field)
	encode H1TEKST,gen(edu_level)
* rename variables
	rename elev3_vtil edu_stopdate
	rename elev3_vfra edu_startdate
	rename udel edu_part
	rename afg_art edu_stopreason
	rename udd edu_udd
	rename audd edu_audd
	rename instnr edu_instid
* keep variables and obs we need
	keep pnr edu* treat*
	keep if inlist(treat_placebo,0,1)
	drop if treat_placebo==0 & treat_treated==0 
* save
	compress
	order pnr edu* treat*
	save "$tf\cohort.dta",replace




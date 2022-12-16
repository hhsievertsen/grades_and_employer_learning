/*		11_edu_define_education_spells.do: find all completed spells (to calcualte GPAs)
		created: 		hhs 16/5/2018
		edited:			ath 12/9/2018 (added more instnr)
						hhs 13/9/2018 (added education_group)
						hhs 03/7/2020 (added education groups)
*/

* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
forval udel=61/62{
	/* kotre */
	use "$rf\kotre.dta",clear
	* keep university degree
	tostring udd, replace
	merge m:1 udd using "$ff\uddan_2014_udd",nogen keep(1 3)
	keep if inlist(h1,"60","65")
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

	* discipline
	encode M1TEKST,gen(discipline)
	encode text,gen(education)
	encode U1TEKST,gen(education_group)
	*graduate programs only
	replace udel=62 if udel==60 
	keep if udel==`udel' /*Intet slettes her*/
	* keep graduated
	collapse (max) elev3_vtil audd discipline (min)  elev3_vfra , by(pnr udd instnr education education_group )/
	gen graduated=audd!=0
	replace graduated=0 if audd==9999 /* igang*/
	keep if graduated==1
	* keep first degree
	bys pnr: egen min=min(elev3_vtil)
	keep if min==elev3_vtil
	*drop duplicates
	sort pnr
	by pnr: keep if _n==1
	gen ku=inlist(instnr,101455,101443,147410,101441)
	keep pnr ku elev3_vtil elev3_vfra discipline education education_group
	keep if year(elev3_vfra)<2011 & year(elev3_vfra)>=2000
	compress
	save "$tf\graduates_level`udel'.dta",replace
	
}

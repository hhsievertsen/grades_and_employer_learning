/*		12_edu_prepare_grade_data.do: adjust KU and AU data to be ready for later matching; 
		created: 		hhs 24/2/2018 
		edited:			hhs 18/3/2018 
						hhs 16/4/2018 (cleaning)
						ath 13/8/2018 (comment row 70)
						hhs 10/7/2020 (followed up on Annes comment and did some cleaning)
*/

* load globals
		do  "K:\Workdata\706831\grading\do_files/globals.do"
* KU
	use "$rf\ku_karakterer.dta",clear
	drop if OPSAMLET_RAMME=="N"
	keep  pnr   ects  fagnavn OPR_KARAKTER karakter   bedoemmelsesdato 
	format bedoemmelsesdato %td
	replace bedoemmelsesdato=bedoemmelsesdato+mdy(1,1,1900)
	sort pnr bedoemmelsesdato 
	* duplicates
	bys pnr bedoemmelsesdato fagnavn   ects:keep if _n==1
	* subject
	gen fagnavn_ch=fagnavn
	bys fagnavn: gen n=_N
	replace fagnavn="" if n<10
	encode (fagnavn),gen(subject) 
	drop n  
	* ignore ects when failed 
	drop if ects==0
	gen edu_ects_raw=ects
	rename  ects edu_ects
	replace edu_ects=0 if !inlist(karakter,"02","4","7","10","11","12","13","B")
	bys pnr bedoemmelsesdato subject fagnavn_ch karakter edu_ects: keep if _n==1
	compress
	save "$tf\ku_karakterer.dta",replace
  
* AU
	use   "$rf\au_karakterer.dta",clear
	drop if admenhed=="Aarhus Universitet" /* aggregate grades (i.e. 1. aarsproeve, etc) */
	destring pnr, replace
	rename belastning edu_ects 
	rename OPRINDELIG_KARAKTER OPR_KARAKTER
	* duplicates
	bys pnr bedoemmelsesdato langtnavn   edu_ects: keep if _n==1
	* subject
	gen fagnavn_ch=langtnavn
	bys langtnavn: gen n=_N
	replace langtnavn="" if n<10
	encode (langtnavn),gen(subject) 
	drop n 
	* ignore ects when failed 
	drop if edu_ects==0
	gen edu_ects_raw=edu_ects
	replace edu_ects=0 if !inlist(karakter,"02","4","7","10","11","12","13","B")
	* duplicates
	bys pnr bedoemmelsesdato subject fagnavn_ch karakter edu_ects: keep if _n==1
	compress
	keep pnr edu_ects  OPR_KARAKTER karakter   bedoemmelsesdato  subject edu_ects_raw
	save "$tf\au_karakterer.dta",replace
	
/* Append data*/
	use "$tf\ku_karakterer.dta",clear
	gen byte edu_ku=1
	append using "$tf\au_karakterer.dta"
	replace edu_ku=0 if edu_ku==.
	bys pnr edu_ects fagnavn_ch OPR_KARAKTER karakter bedoemmelsesdato: gen a=_n
	drop if a>1
	drop a
	gen gradeid=_n
	save "$tf\grades.dta",replace
	

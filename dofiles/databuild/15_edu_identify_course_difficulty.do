/*		14_edu_identify_course_difficulty.do: identify how tough units are
		created: 		hhs 27/4/2018 
		edited: 		hhs 10/7/2020 (
*/

* load globals
		do  "K:\Workdata\706831\grading\do_files/globals.do"
* KU
	use "$tf\grades.dta",clear
* hs gpa
	merge m:1 pnr using "$tf\gpa.dta", nogen keep(3)
* karakter
	destring karakter,replace force
	keep if year(bedoemmelse)<2006
	keep if year(bedoemmelse)>1999
* fe
	reghdfe karakter cov_gpa ,absorb(subject) resid
	predict t,res
	collapse (mean) edu_subgrade_fe=t ///
	                edu_subgrade_actual=karakter ///
					edu_subgrade_selection=cov_gpa , by(subject) fast

* save
	save "$tf\grades_toughness.dta",replace


	

/*		19_create_samples: create samples
		created: 			hhs 18/4/2018 
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
* 1 maindata for graduates
	cap program drop myprog
	program myprog
	syntax, treated(string) year(string)	
		use "$tf\labeldata`treated'`year'.dta",clear
		// sample selection
		drop if edu_pregpa7_std==.
		keep if edu_graduated==1 & edu_ects_tot_post!=0
		keep if  edu_ects_to_go<=40
		
		save "$tf\graduate_data`treated'`year'.dta",replace
	end
	* run
	myprog,treated(1) year(2007) 
	forval i=2001/2006{
		myprog,treated(0) year(`i') 
	}
	

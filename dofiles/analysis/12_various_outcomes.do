/* 		12_various_outcomes.do:  various outcomes
				edited: 		hhs 20/08/2020
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// load data 
use  "$tf\graduate_data12007.dta",clear
// create new outcomes 
* create growth variables
gen earnings_growth_1=.
gen earnings_growth_2=outcome_learnings_2-outcome_learnings_1
gen earnings_growth_3=outcome_learnings_3-outcome_learnings_2
gen earnings_growth_4=outcome_learnings_4-outcome_learnings_3
gen earnings_growth_5=outcome_learnings_5-outcome_learnings_4
* accumulated earnings 
replace outcome_earnings_1=. if outcome_earnings_1==0
replace outcome_earnings_2=. if outcome_earnings_2==0
replace outcome_earnings_3=. if outcome_earnings_3==0
replace outcome_earnings_4=. if outcome_earnings_4==0
replace outcome_earnings_5=. if outcome_earnings_5==0
gen outcome_alearnings_1=log(outcome_earnings_1)
gen outcome_alearnings_2=log(outcome_earnings_2+outcome_earnings_1)
gen outcome_alearnings_3=log(outcome_earnings_3+outcome_earnings_2+outcome_earnings_1)
gen outcome_alearnings_4=log(outcome_earnings_4+outcome_earnings_3+outcome_earnings_2+outcome_earnings_1)
gen outcome_alearnings_5=log(outcome_earnings_5+outcome_earnings_4+outcome_earnings_3+outcome_earnings_2+outcome_earnings_1)
// loop over years
	forval i=1/5{
		local j=`i'-1
		* any earnings
		gen outcome_anyearnings_`i'=outcome_learnings_`i'!=.
		label var outcome_anyearnings_`i' "Earnings $>0$"
		* disp income conditional on any earnings
		gen outcome_ldispincomea_`i' =outcome_ldispincome_`i' if outcome_anyearnings_`i'==1>0
		label var outcome_ldispincomea_`i' "Log disp. income in year, cond. on earnings $>$0"
		* job change
		replace outcome_jobchange_`i'=. if outcome_jobchange_`i'==99
		* job change and earnings growth
		gen outcome_jobchangeplus_`i'=0 if outcome_jobchange_`i'==1
		cap replace outcome_jobchangeplus_`i'=1 if  earnings_growth_`i'>0.019 & earnings_growth_`i'!=. & outcome_jobchange_`i'==1
		cap label var outcome_jobchangeplus_`i' "Job change with earnings growth"
		* earnings growth		
		cap label var earnings_growth_`i' "Earnings growth year"
		* earnings growth same job
		cap gen earnings_samegrowth_`i'=earnings_growth_`i' if outcome_jobchange_`i'==0
		cap label var earnings_samegrowth_`i' "Earnings growth, cond. on same job"
	}
	

// loop over outcomes
foreach outcome in outcome_anyearnings_   outcome_ldispincome_ outcome_ldispincomea_ outcome_unemployment_ outcome_public_sector_ outcome_jobchange_ outcome_jobchangeplus_  earnings_growth_ earnings_samegrowth_{
	eststo clear
	// loop over years
	forval year=1/5{
		// Regress
			cap  qui: eststo:  reg `outcome'`year'	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2 edu_pregpa7w, cluster(edu_gpa_group)	
		
	}
	// save label
	local lab: variable label `outcome'1
	label var edu_pregpa7w "`lab'"
	// generate table
	if "`outcome'"!="outcome_anyearnings_"{
	esttab using "$df\tab_reg_varoutcomes.tex",  fragment 	 star(* 0.1 ** 0.05 *** 0.01) nomtitles  noobs nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w) append label
	}
	else{
		esttab using "$df\tab_reg_varoutcomes.tex",  fragment 	replace star(* 0.1 ** 0.05 *** 0.01) nomtitles  noobs nolines nogaps nonumbers se b(%6.3f) keep(edu_pregpa7w)  label
	}
	
	
		
  reg earnings_samegrowth_2 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1 $cov2 edu_pregpa7w, cluster(edu_gpa_group)	
}
	
	
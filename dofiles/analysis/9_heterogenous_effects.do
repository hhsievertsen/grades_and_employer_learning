/* 		9_hetero.do: heterogenous effect
		created: 		hhs 14/9/2018  (new specs)
		edited: 		ath 28/11/2018 (new specs)
						ath 09/01/2019 (new specs)
						hhs 18/8/2020  
		                
*/
// Load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// Load data Load data 
use  "$tf\graduate_data12007.dta",clear
// Indicator for high GPPA
sum edu_pregpa13w,d
gen above=edu_pregpa13w>r(p50) 
eststo clear
// labels
label var cov_female  "Female="
label var above "GPA above median="
label var cov_parental_schooling_uni "Parents w. university degree="
label var edu_high_wage_dispersion "Wage dispersion above median="
label var edu_high_public_share "Public sector share above median="
label var edu_high_earnings_study "Earnings while studying above median="
label var edu_ku "University of Copenhagen="
// Loop over heterogeneity dimensions
	foreach dim in cov_female  above cov_parental_schooling_uni  edu_high_wage_dispersion edu_high_public_share  edu_high_earnings_study edu_ku {
	// Loop over 0 and 1
	forval d=0/1{
		// Loop over years
			forval i=1/5{
			    // create label
			local lab : variable label `dim'
			label var edu_pregpa7w "\multicolumn{2}{l}{`lab'`d'}"
				// pre estimations for suest 
				qui: reg outcome_learnings_`i'	 edu_high_public_share    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1  edu_pregpa7w edu_high_public_share  if `dim'==`d', 
				estimates store s`d'_`i'
				// run suest
				if `d'==1{
					qui: suest s0_`i' s1_`i', cluster(edu_gpa_group)
					qui: qui: test [s0_`i'_mean]edu_pregpa7w=[s1_`i'_mean]edu_pregpa7w
					local pval=r(p)
				}
				// for table
				qui: reg outcome_learnings_`i' 	 edu_high_public_share    edu_pregpa13w2 edu_pregpa13w3  $cov0 $cov1  edu_pregpa7w edu_high_public_share  if `dim'==`d', cluster(edu_gpa_group)
				eststo m`d'_`i'
				// add p val
				if `d'==1{
					qui: estadd scalar pval=`pval'
				}
			}
			// Save table
			if `d'==1{
					esttab  m1_1  m1_2  m1_3  m1_4  m1_5 using "$df\tab_hetero.tex", fragment nolines nogaps nomtitles nodepvars nonumbers stats(pval,fmt(%4.2f) label("&P-val")) b(%4.3f) keep(edu_pregpa7w)    ///
			   se  append noobs label
				}
				else if `d'==0 & "`dim'"!="cov_female"{
				    	esttab m0_1 m0_2 m0_3 m0_4 m0_5  using "$df\tab_hetero.tex", fragment nolines nogaps nomtitles nodepvars nonumbers  keep(edu_pregpa7w)  b(%4.3f) append  noobs ///
			   se  label
				}
				else{
				 	    	esttab m0_1 m0_2 m0_3 m0_4 m0_5  using "$df\tab_hetero.tex", fragment nolines nogaps nomtitles nodepvars nonumbers  keep(edu_pregpa7w) b(%4.3f) replace noobs  ///
			   se  label   
				}
			}
}





eststo clear
forval i=1/5{
qui: 	eststo: reg  outcome_learnings_`i'  	$cov0 $cov1 $cov2  edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 edu_pregpa7w if outcome_public_sector_`i'==0, cluster(edu_gpa_group) 
}
esttab, keep(edu_pregpa7w) se star(* 0.1 ** 0.05 *** 0.01)
eststo clear

forval i=1/5{
qui: 	eststo: reg  outcome_learnings_`i'  	$cov0 $cov1 $cov2  edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3 edu_pregpa7w if outcome_public_sector_`i'==1, cluster(edu_gpa_group) 
}
esttab, keep(edu_pregpa7w) se star(* 0.1 ** 0.05 *** 0.01)

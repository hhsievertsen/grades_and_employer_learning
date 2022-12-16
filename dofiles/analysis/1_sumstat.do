/* 		1_sumstat.do:  summary stat; 
		created: 		hhs 24/2/2018 
		edited:		    hhs 14/9/2018 added more moments etc
						hhs 17/7/2020 cleaning
*/
// load globals
do  "K:\Workdata\706831\grading\do_files/globals.do"
// Program to generate summary stats
cap program drop mystats
program mystats
	syntax varlist using
	cap file close myfile
	file open myfile `using', replace write
	foreach var in `varlist'{
			qui:sum `var' 
			local m: di %4.2f r(mean)
			local sd: di %4.2f r(sd)
			qui: mypercentile `var' ,p(25)
			local p25: di %4.2f r(p25)
			qui: mypercentile `var' ,p(50)
			local p50: di %4.2f r(p50)
			qui: mypercentile `var' ,p(75)
			local p75: di %4.2f r(p75)
			* write
			local lab: var label `var'
			file write myfile "`lab'& `m' &  `sd' & `p25' & `p50' & `p75'  \\"_n
		}
		
		file write myfile "\midrule"_n
		qui: sum edu_ku 
		local N: di %15.0g r(N)
		file write myfile "Observations &  `N' \\"_n
		file close myfile
end
// load data
use "$tf\labeldata12007.dta",clear
// sample selection
drop if edu_pregpa7_std==.
keep if  edu_ects_to_go<=40
keep if edu_graduated==1 & edu_ects_tot_post!=0
// set missing values to missing
replace cov_hs_gpa=. if cov_hs_gpa_m==1
replace cov_age=. if cov_age_m==1
replace cov_female=. if cov_female_m==1
replace cov_nonwestern=. if cov_nonwestern_m==1
replace cov_parental_income=. if cov_parental_incobserved==0
replace cov_parental_schooling=. if  cov_parental_schoolingobserved==0 
replace cov_parental_schooling_uni=. if  cov_parental_schoolingobserved==0 
// generate table
mystats cov_age cov_female   ///
		cov_parental_income cov_parental_schooling cov_parental_schooling_uni ///
		edu_ku  edu_ects_to_go edu_pre_share edu_pregpa7w  edu_gpaw ///
		outcome_worked_1 outcome_earnings_1 outcome_public_sector_1 outcome_unemployment_1 ///
		using "$df\tab_sumstat.tex"
		

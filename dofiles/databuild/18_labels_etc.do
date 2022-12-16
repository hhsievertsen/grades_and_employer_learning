/*		18_labels_etc; 
		created: 		hhs 24/2/2018 
		edited:			hhs 18/4/2018 (cleaning)
		edited: 		ath 28/11/2018 (adding public share)
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
* a small program to create 
cap program drop myprog
program myprog
syntax, treated(string) year(string)
	use "$tf\rawdata_treated`treated'`year'.dta", clear
	label var edu_startdate 		"Date enrollen in program"
	label var edu_stopdate 			"Date of leaving program"
	label var edu_education 		"Program studied"
	label var edu_field 			"Faculty"
	label var edu_ku 				"University of Copenhagen"
	label var edu_ects_tot_graded_pre 	"ECTS points pre recoding, graded"
	label var edu_ects_tot_graded_post 	"ECTS points post recoding, grade"
	label var edu_ects_tot_pre 		"ECTS points pre recoding, total"
	label var edu_ects_tot_post		"ECTS points post recoding, tot"
	label var edu_subgrade_fe 		"Subject FE"
	label var edu_pregpa7 			"Recoded GPA"
	label var edu_pregpa13 			"Original GPA"
	label var edu_postgpa 			"GPA of grades given after"
	label var edu_pregpa7w 			"Recoded GPA, weighted"
	label var edu_pregpa13w 		"Original GPA, weighted"
	label var edu_postgpaw 			"GPA of grades given after, weighted"
	label var edu_gpaw 				"Final GPA, weighted"
	label var edu_year 				"Year graduated"
	label var edu_graduated 		"Graduated"
	label var edu_enrolyear 		"Year enrolled in program"
	label var edu_stopyear 			"Year leaving program"
	label var cov_female 			"Female"
	label var cov_nonwestern 		"Non-western origin"
	label var edu_high_wage_dispersion	"Wage dispersion above median"
	label var edu_ratio				"Wage disperion: P90/P50"
	label var cov_parental_schooling_uni 	"Parents' with university degree"
	label var edu_high_public_share	 "Share of public workers above median" 
	label var edu_high_earnings_study "Study earnings above median"
	rename cov_gpa_m cov_hs_gpa_m
	rename cov_gpa cov_hs_gpa 
	label var cov_hs_gpa 				"High school GPA"
	label var cov_hs_gpawritten 				"High school GPA, written exams"
	label var cov_undergrad_gpa		"Undergrad GPA (SD)"
	label var cov_age 				"Age at graduation (years)"
	label var cov_parental_incobserved 	"Parental income, observed"
	label var cov_parental_income 		"Average parental income (1,000 Euro)"
	label var cov_parental_uneobserved 	"Parental unemployment, observed"
	label var cov_parental_une 			"Parental unemployment"
	label var cov_parental_schoolingobserved 	"Parental schooling, observed"
	label var cov_parental_schooling 			"Parental schooling, years"
	label var cov_female_m 						"Female is missing"
	label var cov_nonwestern_m 					"Non-western is missing"
	label var cov_hs_gpa_m 						"HS GPA is missing"
	label var cov_age_m							"Age is missing"
	label var  edu_pre_share 					"Share of ECTS pre recoding"
	label var edu_failed_post 					"Failed post recoding"
	label var edu_ects_tot_graded				"Total ECTS, graded"
	label var edu_ects_tot						"Total ECTS"
	forval i=0/5{
		label var outcome_learnings_`i' "Log earnings in year `i'."
		label var outcome_earnings_`i' "Log earnings in year `i'"
		label var outcome_worked_`i' "Earnings>0 in year `i' "
		label var outcome_public_sector_`i' "Public sector in year `i'"
		label var outcome_ldispincome_`i' "Log disp. income in year `i'"
		label var outcome_lgrossincome_`i' "Log gross income in year `i'"
		label var outcome_grossincome_`i' "Gross income in year `i'"
		label var outcome_dispincome_`i' 	"Disp. income in year `i'"
		label var outcome_jobchange_`i' 	"Job change in year `i'"
		label var outcome_unemployment_`i' 	"Unemployment in year `i'"
		label var outcome_selfemployed_`i' 	"Selfemployed in year `i'"
		label var outcome_ever_unemployed_`i' 	"Unemployed in year `i'"
		 
		
	}
	/* GPA group (for clustering)*/
		gen edu_gpa_group=round(edu_pregpa13w,.1)
	/* collapse fields */
		replace edu_field=1 if edu_field==2
		replace edu_field=5 if edu_field==9
		replace edu_field=3 if edu_field==6
		replace edu_field=3 if edu_field==4
		replace cov_parental_uneobserved=0 if cov_parental_une==.
		replace cov_parental_une=0 if cov_parental_une==.
	/* time to graduation */
		gen edu_time_to_grad=(edu_stopdate-mdy(7,31,`year'))/365.24 if edu_graduated==1
		*replace edu_time_to_grad=edu_ects_tot_post/edu_time_to_grad
		label var edu_time_to_grad "Time to graduation"
	/* reweighted GPA */
		gen edu_pregpa7w_rweighted=edu_pregpa7w* edu_pre_share
		gen edu_postgpaw_rweighted=edu_postgpaw* (1-edu_pre_share)
		label var edu_pregpa7w_rweighted "Pre GPA, weighted by total"
		label var edu_postgpaw_rweighted "Post GPA, weighted by total"
		label var edu_ects_to_go "ECTS remaining"
	/* Standardize*/
		foreach i in edu_postgpaw_rweighted edu_pregpa7w_rweighted edu_pregpa7 edu_pregpa13 edu_postgpa edu_pregpa7w edu_pregpa13w edu_postgpaw edu_gpaw {
				bys  edu_education edu_year: egen m=mean(`i')
				bys  edu_education edu_year: egen sd=sd(`i')
				gen  `i'_std=(`i'-m)/sd
				drop m sd
				local lab: var lab `i'
				label var `i'_std "`lab' (STD)"
				gen `i'2=`i'*`i'
				gen `i'3=`i'*`i'*`i'
				gen `i'4=`i'*`i'*`i'*`i'
				label var `i'2 "`lab', squared"
				label var `i'3 "`lab', cubic"
				gen `i'_std2=`i'_std*`i'_std
				gen `i'_std3=`i'_std*`i'_std*`i'_std
				gen `i'_std4=`i'_std*`i'_std*`i'_std*`i'_std
				label var `i'_std2 "`lab' (STD), squared"
				label var `i'_std3 "`lab' (STD), cubic"
		}
		
		save "$tf\labeldata`treated'`year'.dta",replace
end
* run
myprog,treated(1) year(2007) 
forval i=2001/2006{
	myprog,treated(0) year(`i') 
}



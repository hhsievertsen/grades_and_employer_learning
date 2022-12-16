/* 		create spec curve data
		created: 		hhs 17/10/2019  
		edited: 		hhs 20/08/2020
*/
// load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
// dataset to save estimates
	clear
	gen beta=.
	gen se=.
	gen covars=.
	foreach i in 45 40 35  {
		gen ectslimit`i'=.
	}
	gen spec2ndorder=.
	gen spec3rdorder=.
	gen spec4thorder=.
	gen specnpmean=.
	gen year2009=.
	gen year2010=.
	gen year2011=.
	gen ngraduated=.
	gen placebo=.
	gen specnumber=.
	save "$tf\estimatesforechart.dta",replace
// Program to store estiamtes
	cap program drop stor
	program stor
		preserve
		use "$tf\estimatesforechart.dta",clear
		local N=_N+1
		set obs `N'
		replace specnumber=`N' if specnumber==.
		replace beta=_b[`1'] if specnumber==`N'
		replace se=_se[`1'] if specnumber==`N'
		forval i=2/10{
			if "`i'"!=""{
				cap replace ``i''=1 if specnumber==`N'
				}
		}
		save "$tf\estimatesforechart.dta",replace
	end
	
local r=200
// loop over years
foreach year in  2011 2010 2009{
	// loop over ects
	foreach ects in  45 40 35 {
		// load data

		use "$tf\labeldata12007.dta",clear
		// sample select
		drop if edu_pregpa7_std==.
		keep if  edu_ects_tot_post!=0 
		keep if !inlist(edu_audd,0,9999)
		keep if edu_stopyear<=`year'
		keep if edu_ects_to_go<`ects'
	/************************* With covars ***************************************/
		/* 2nd order */
		 qui: reg outcome_learnings_1 edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2   $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		 stor edu_pregpa7w  covars  spec2ndorder year`year' ectslimit`ects'
		/* 3th order*/
		 qui: reg outcome_learnings_1 edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2  edu_pregpa13w3  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		 stor edu_pregpa7w  covars  spec3rdorder year`year' ectslimit`ects'
		/* 4th order*/
		 qui: reg outcome_learnings_1 edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2  edu_pregpa13w3 edu_pregpa13w4  $cov0 $cov1 $cov2, cluster(edu_gpa_group)
		 stor edu_pregpa7w  covars  spec4thorder year`year' ectslimit`ects'
		/* Deviation from median*/
			gen g=round(edu_pregpa13w,.1)
			sort g
			* drop small groups
			by g: gen N=_N
			by g: egen yhat=mean(edu_pregpa7w)
			gen res=edu_pregpa7w-yhat
			replace g=round(g*10)
			qui: reg outcome_learnings_1 res	 i.g  $cov0 $cov1 $cov2 if N>5, cluster(edu_gpa_group)
			drop g yhat res N
			
			stor res  covars  specnpmean year`year' ectslimit`ects'
	/************************* Without covars ***************************************/
			/* 2nd order */
		 qui: reg outcome_learnings_1 edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2   $cov0  , cluster(edu_gpa_group)
		 stor edu_pregpa7w    spec2ndorder year`year' ectslimit`ects'
		/* 3th order*/
		 qui: reg outcome_learnings_1 edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2  edu_pregpa13w3  $cov0  , cluster(edu_gpa_group)
		 stor edu_pregpa7w    spec3rdorder year`year' ectslimit`ects'
		/* 4th order*/
		 qui: reg outcome_learnings_1 edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2  edu_pregpa13w3 edu_pregpa13w4  $cov0  , cluster(edu_gpa_group)
		 stor edu_pregpa7w    spec4thorder year`year' ectslimit`ects'
		/* Deviation from mean*/
			gen g=round(edu_pregpa13w,.1)
			sort g
			* drop small groups
			by g: gen N=_N
			by g: egen yhat=mean(edu_pregpa7w)
			gen res=edu_pregpa7w-yhat
			replace g=round(g*10)
			 qui:  reg outcome_learnings_1 res	 i.g  $cov0   if N>5, cluster(edu_gpa_group)
			drop g yhat res N
			stor res    specnpmean year`year' ectslimit`ects' 
					
	}
}
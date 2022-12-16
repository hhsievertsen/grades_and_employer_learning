clear
set max_memory 40g
set more off 

* clobals
cd "K:\workdata\706831\grading"
global tf "K:\workdata\706831\grading\temporary_files"
global df "K:\workdata\706831\grading\download_files"
global ff "K:\workdata\706831\grading\format_files"
global rf "k:\workdata\706831\stata_files"
global dc "K:\workdata\706831\grading\temporary_files\datacheck"


* models
global uncon "edu_pregpa7w	"
global mainspec "edu_pregpa7w	 edu_pregpa13w    edu_pregpa13w2 edu_pregpa13w3"
global spec1 "edu_pregpa7w	 edu_pregpa13w  edu_pregpa13w2  "
global spec2 "edu_pregpa7w	 edu_pregpa13w  edu_pregpa13w4  edu_pregpa13w3 "
global  cov0 "ib(44).edu_education edu_ku  "
global  cov1 " 	  cov_age cov_nonwestern cov_female ib(0).cov_parental_incobserved cov_parental_income i.cov_parental_uneobserved cov_parental_une ib(0).cov_parental_schoolingobserved cov_parental_schooling_uni cov_female_m cov_nonwestern_m cov_age_m "
global  cov2 "cov_hs_gpa cov_hs_gpa_m    "

* add adopath
adopath + "K:\workdata\706831\grading\adofiles"

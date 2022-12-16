/*		08_labor_market_income_spells.do: create_monthly_income_spells
		created: 		hhs 22/14/2020
*/
* load globals
do "K:\workdata\706831\grading\do_files\globals.do"
* loop over years
forval i=2007/2011{
	* load ras data 
	use "$rf\rasv`i'.dta",clear
		
	
	*keep what we need
	replace  smalt_loenbeloeb=loenblb if `i'<2008
	drop if smalt_loenbeloeb==. | smalt_loenbeloeb==0 | smalt_loenbeloeb<0
	keep pnr ansfra anstil smalt_loenbeloeb   arbnr helarkod novprio heltid_deltid_kode
	rename smalt_loenbeloeb earnings
	* convert to fixed prices
	replace earnings=earnings*(100/76.2) if `i'==2000 /* Adjusted uing CPI */
	replace earnings=earnings*(100/78.0) if `i'==2001
	replace earnings=earnings*(100/79.9) if `i'==2002
	replace earnings=earnings*(100/81.6) if `i'==2003
	replace earnings=earnings*(100/82.5) if `i'==2004
	replace earnings=earnings*(100/84.0) if `i'==2005
	replace earnings=earnings*(100/85.6) if `i'==2006
	replace earnings=earnings*(100/87.1) if `i'==2007
	replace earnings=earnings*(100/90.1) if `i'==2008
	replace earnings=earnings*(100/91.2) if `i'==2009
	replace earnings=earnings*(100/93.3) if `i'==2010
	replace earnings=earnings*(100/95.9) if `i'==2011
	replace earnings=earnings*(100/98.2) if `i'==2012
	replace earnings=earnings*(100/99.0) if `i'==2013
	replace earnings=earnings*(100/99.6) if `i'==2014
	replace earnings=earnings*.00013 /* 1.000 EURO */
	* adjust fulltime parttime

	* correct dates
	gen all_year=0
	replace all_year=1 if year(ansfra)==1960 & ansfra==anstil
	replace all_year=1 if year(anstil)==1960 & ansfra==anstil
	replace all_year=1 if ansfra==.
	replace ansfra=mdy(1,1,`i') if all_year==1 | helarkod==1
	replace anstil=mdy(12,31,`i') if all_year==1 | helarkod==1
	* spell id
	bys pnr: gen spell_id=_n
	* expand to months
	expand 12
	bys pnr spell_id: gen month=_n
	* calculate  month coverage
	gen int days_in_month=day(mdy(month+1,1,`i')-1) /* number of days in this month */
	replace days_in_month=31 if month==12
	cap drop monthcoverage /* number of days included in spell */
	gen int monthcoverage=0
	replace monthcoverage=min(mdy(month,days_in_month,`i'),anstil) -max(ansfra,mdy(month,1,`i'))+1 if anstil>=mdy(month,1,`i')&ansfra<=mdy(month,days_in_month,`i')
	gen covered=monthcoverage>0
	* spell length
	gen int spell_length=anstil-ansfra+1
	* gen monthly income
	gen monthly_income=earnings* monthcoverage/spell_length
	* month
	gen ym=ym(`i',month)
	format ym %tm
	* employers
	destring arbnr, gen(firmid) force
	gen a=monthly_income if covered==1
	gen nov=novprio==1
	replace a=-1 if a==.
	sort pnr ym covered nov a
	by pnr ym: replace firmid=. if _n!=_N
	replace firmid=. if covered==0
	* collapse
	collapse (sum) monthly_income   days_worked=monthcoverage  employers=covered ///
	    (firstnm) firmid ,by(ym pnr) fast
	save "$tf\monthly_earnings`i'.dta",replace
}
clear
forval i=2007/2011{
	append using "$tf\monthly_earnings`i'.dta"	
}
compress
/* spell info */
sort pnr ym
gen spell_duration=1
by pnr: replace spell_duration=spell_duration[_n-1]+1 if firmid==firmid[_n-1] & ym==ym[_n-1]+1
replace spell_duration=. if firmid==.
save "$tf\monthly_earningspanel.dta",replace
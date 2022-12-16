/*		4_hw.do: creates data file labor market variables; 
		created: 		hhs 24/2/2018 
		edited:			hhs 16/3/2018 (replace bredt_loeblelob if missing)
							edited:			hhs 13/8/2020, cleaning
*/
* load globals
	do  "K:\Workdata\706831\grading\do_files/globals.do"
/* Loop over RAS to get hw */
	forval i=2003/2015{
		if `i'<2009{
			use "$rf\lon`i'.dta",clear
			gen hw=gw-w_abs
			*dad
			keep pnr timprae sektor hw
			
			}
		if `i'>2008{
			use "$rf\lonn`i'.dta",clear
			gen hw=maaned_stand/160.33
			keep pnr timprae sektor hw
		}
		bys pnr: egen max=max(timprae)
		destring sektor, replace force
		replace sektor=0 if round(timprae)!=round(max)
		replace hw=hw*timprae
		* collapse to one obs
		
		collapse (sum) hw timprae (max) sektor,by(pnr)
		replace hw=hw/tim
		* convert hw to 2015 values in thousand Euros, using CPI from DST
		replace hw=hw*(100/76.2) if `i'==2000
		replace hw=hw*(100/78.0) if `i'==2001
		replace hw=hw*(100/79.9) if `i'==2002
		replace hw=hw*(100/81.6) if `i'==2003
		replace hw=hw*(100/82.5) if `i'==2004
		replace hw=hw*(100/84.0) if `i'==2005
		replace hw=hw*(100/85.6) if `i'==2006
		replace hw=hw*(100/87.1) if `i'==2007
		replace hw=hw*(100/90.1) if `i'==2008
		replace hw=hw*(100/91.2) if `i'==2009
		replace hw=hw*(100/93.3) if `i'==2010
		replace hw=hw*(100/95.9) if `i'==2011
		replace hw=hw*(100/98.2) if `i'==2012
		replace hw=hw*(100/99.0) if `i'==2013
		replace hw=hw*(100/99.6) if `i'==2014
		replace hw=hw*.13 /* EURO */
		* save
		gen public_sector=sektor!=1
		rename timprae hours
		keep pnr hw public_sector hours
		gen lhw=log(hw)
		compress
		save "$tf\hw`i'.dta",replace
	}
/* append to one dataset */
	use  "$tf\hw2015.dta",clear
	gen int year =2015
	forval i=2003/2014{
		append using "$tf\hw`i'.dta"
		replace year=`i' if year==.
	}
/* save long format*/
	mdd,y(year)
	compress
	save "$tf\hwlong.dta",replace
	


* create percentiles across several values
cap program drop mypercentile
program mypercentile,rclass
syntax varlist(max=1),p(string) [minN(real 5)]
tempfile data
qui: 	 save `data',replace
qui: keep if `varlist'!=.
	qui: centile `varlist',centile(`p')
	local true_p= r(c_1)
	sort  `varlist'
	* find values
	gen dist=abs(`varlist'-`true_p')
	qui: sum dist
	qui: gen include=1 if dist==r(min)
	qui: sum `varlist' if include==1
	local N=r(N)
	if `N'>=`minN'{
		return scalar p`p'=r(mean)
		return scalar N=`N'
	}
	else{
	gen n=_n
	qui: sum n if include==1
	local lower=r(min)-1
	local upper=r(max)+1
		while `N'<`minN'{
			qui: replace include=1 if n==`lower' | n==`upper'
			qui: sum `varlist' if include==1
			local N=r(N)
			local lower=`lower'-1
			local upper=`upper'+1
			}
		return scalar p`p'=r(mean)+0
		return scalar N=`N'+0
	}
qui: use `data',clear
end
 
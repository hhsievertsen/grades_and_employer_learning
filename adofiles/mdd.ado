	* My duplicates drop mdd, considerably faster than duplicates drop 
	cap program drop mdd
	program mdd
		syntax ,[y(string)]
			bys pnr `y': gen n=_n
			keep if n==1
			drop n
		
	end

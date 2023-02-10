/// creating neighbors and latent tie variables

import delimited risk_states.csv, clear

rename state statename
drop if missing(category)
rename v23 state
replace statename="Louisiana" if statename=="Lousiana"
replace state="LA" if statename=="Louisiana"
/// needs to be solved asap
duplicates drop state category year, force

  encode category, gen(policyno)
  bysort category: egen first_year1=min(year) if policy==1
  bysort category: egen first_year=mean(first_year1)
  
  drop if year<first_year

/// creating measure of sum of previously adopting  contiguous states
sources policy, generate(contig_adpt) id(state) time(year) sources(contiguous) policy(category)



/// creating latent tie measure
sources policy, generate(latnt_adpt) id(state) time(year) ///
sources(src_10_400) policy(category) sourcefile(sources_latent.dta)
/// creating lagged measure

  sort category stateno year
  bysort category stateno: generate nbrs= sum(contig_adpt)
  bysort category stateno: generate nbrs_lag=0 if _n==1
  bysort category stateno: replace nbrs_lag=nbrs[_n-1] if _n>1
  
  order state year policy category nbrs_lag

  
 sort policyno state year
	generat latnt_lag = 0 if year == first_year
	replace latnt_lag = latnt_adpt[_n-1] if year > first_year ///
	& state==state[_n-1]
	
	
	
	export delimited using "risk_states1", replace
	
	
	
	

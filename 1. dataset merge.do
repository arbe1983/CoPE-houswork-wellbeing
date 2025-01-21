*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	  	   DATASET MERGE 			 			   		   *
*------------------------------------------------------------------------------*

clear all
set maxvar 10000
	
*--------------------------------------------------
* Select work folders 						 						     
*-------------------------------------------------- 
housework "INSERT YOUR WORKING FOLDER PATH"

global code			"$housework/Analyses"
global data			"$housework/Data"
global output 		"$housework/Output"

global w12 	 	 "$data\UKHLS12\6614stata_961F73F240850C31685A64327005C005F22A54B671C5F82433DEA980DDFE4CA1_V1\UKDA-6614-stata\stata\stata13_se\ukhls"
global cov19 	 "$data\covid19"

*--------------------------------------------------
* Merge waves						 						     
*-------------------------------------------------- 

* merge: start from UKHLS waves 10/11/12

	cd "$w12"
	
	u j_indresp, clear // "j_" refers to wave 10 (which includes housework info, not asked in wave 11)
	rename j_* *
	rename istrtdaty intyear 
	rename istrtdatm intmonth
	ge survey="wave 10"
	save "$data/w10_base", replace
	
	u j_hhresp, clear 
	rename j_* *
	ge survey="wave 10"
	merge 1:m hidp using "$data/w10_base", keep(3) nogen // keep only matched household information (all matched anyway)
	save "$data/w10_base", replace 
	
	u k_indresp, clear // "k_" refers to wave 11
	rename k_* *
	rename istrtdaty intyear 
	rename istrtdatm intmonth
	ge survey="wave 11"
	save "$data/w11_base", replace
	
	u k_hhresp, clear 
	rename k_* *
	ge survey="wave 11"
	merge 1:m hidp using "$data/w11_base", keep(3) nogen // keep only matched household information (all matched anyway)
	save "$data/w11_base", replace 
	
	u l_indresp, clear // "l_" refers to wave 12
	rename l_* *
	rename istrtdaty intyear 
	rename istrtdatm intmonth
	ge survey="wave 12"
	save "$data/w12_base", replace 
	
	u l_hhresp, clear 
	rename l_* *
	ge survey="wave 12"
	merge 1:m hidp using "$data/w12_base", keep(3) nogen // keep only matched household information (all matched anyway)
	save "$data/w12_base", replace 
	
	append using "$data/w10_base"
	append using "$data/w11_base" 
	save "$data/w12_base", replace 
	
* merge: continue with COVID study

	cd "$cov19"

	* web interviews
	local dataid a b c d e f g h i
	foreach ww of local dataid {
		use  "$cov19\c`ww'_indresp_w", clear
		rename i_hidp hidp 
		rename c`ww'_* * 
		save "$data/c`ww'_cov", replace
	}
	
	* telephone interviews
	local t = "b f"
	foreach tt of local w {
		use "$cov19/c`tt'_indresp_t", clear
		rename i_hidp hidp 
		rename c`tt'_* * 
		save "$data/c`tt'_covT", replace
		use "$data/c`tt'_cov", clear 
		append using "$data/c`tt'_covT"
		save "$data/c`tt'_cov", replace 
		erase "$data/c`tt'_covT"
	}

	* append covid waves
	cd "$data" 
	use ca_cov, clear 
	append using cb_cov cc_cov cd_cov ce_cov cf_cov cg_cov ch_cov ci_cov, gen(wavec)
	replace wavec = wavec+1
	ge intyear = . 
		replace intyear = 2020 if inrange(wavec, 1, 6)
		replace intyear = 2021 if inrange(wavec, 7, 9)
	ge intmonth = . 
		replace intmonth = 4 if wavec==1
		replace intmonth = 5 if wavec==2
		replace intmonth = 6 if wavec==3
		replace intmonth = 7 if wavec==4
		replace intmonth = 9 if wavec==5
		replace intmonth = 11 if wavec==6
		replace intmonth = 1 if wavec==7
		replace intmonth = 3 if wavec==8
		replace intmonth = 9 if wavec==9
		ge survey="covid"
		save "$data/cov19_merge", replace  
		local dataid a b c d e f g h i
	foreach d of local dataid {
			erase "$data/c`d'_cov.dta"
	}

* merge: append all waves 

	u "$data/w12_base", clear 
	append using "$data/cov19_merge", gen(COV) // N.B. the data is now in long format

	bys pidp (intyear intmonth): gen t  = _n 
	bys pidp (intyear intmonth): gen mt = _N 
	
* panel data structure 
	
	xtset pidp t
	xtdes
	
*--------------------------------------------------
* Save merge dataset					 						     
*-------------------------------------------------- 
	
save "$data/cope_housework", replace

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*

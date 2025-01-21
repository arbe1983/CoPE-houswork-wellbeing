*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	  	MERGE PARTNERS 			 			   		   	   *
*------------------------------------------------------------------------------*
	
*--------------------------------------------------
* Select work folders 						 						     
*-------------------------------------------------- 
global housework "INSERT YOUR WORKING FOLDER PATH"

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 

u "$data/cope_housework_clean3.dta", clear

*--------------------------------------------------
* Generate couple-level dataset					 						     
*-------------------------------------------------- 

* data from long to wide (1 row of info is sufficient for our design)
	bys pidp(intyear intmonth): ge n=_n
	bys pidp: keep if n==1
	drop n
	
* restrict to individuals who have a spouse/partner in the household
	keep if ppno>0 
	keep if !mi(ppno)
	keep if pno>0 
	keep if !mi(pno)
	
* keep only variables of interest
	keep hidp pidp ppid pno ppno intyear intmonth female age_fixed migback  	///
		 urban edu_3_self d_married kids03 kids46 kids717 totalnumberchildren	///
		 index_distress z_distress change_work* hh_* 
		 
* save dataset 
	save "$data/cope_housework_clean4", replace

* rename all individual characteristics to something that would indicate the characteristics refer to the spouse/partner
	rename * p_*

* rename the spouse/partner pno variable to respondent pno for matching to their partner
	rename p_ppno pno

* rename the hidp back to hidp  
	rename p_hidp hidp

* drop the variable p_pno as it is no longer needed
	drop p_pno 

* save the file temporarily
	save tmp_pinfo, replace

* reopen data file for all enumerated individuals 
	u "$data/cope_housework_clean4", clear

* restrict the variables to individuals who have a spouse/partner in the household
	keep if ppno>0 
	keep if !mi(ppno)
	keep if pno>0 
	keep if !mi(pno)

* merge the data with the data relating to the spouse/partner, using hidp and pno as linking variables 
	merge 1:1 hidp pno using tmp_pinfo
	keep if _merge==3
	drop _merge
	
*--------------------------------------------------
* Save cleaned dataset					 						     
*-------------------------------------------------- 
	
save "$data/cope_housework_clean5", replace
erase tmp_pinfo.dta

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*

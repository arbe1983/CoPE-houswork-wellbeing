*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	  FINAL SAMPLE SELECTION			 			   	   *
*------------------------------------------------------------------------------*

*--------------------------------------------------
* Select work folders 						 						     
*-------------------------------------------------- 
global housework "INSERT YOUR WORKING FOLDER PATH"


global code			"$housework/Analyses"
global data			"$housework/Data"
global output 		"$housework/Output"

global w12 	 	 "$data\UKHLS12\6614stata_961F73F240850C31685A64327005C005F22A54B671C5F82433DEA980DDFE4CA1_V1\UKDA-6614-stata\stata\stata13_se\ukhls"
global cov19 	 "$data\covid19"

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 

u "$data/cope_housework_clean6.dta", clear

*--------------------------------------------------
* No missing cases in variables of interest					 						     
*--------------------------------------------------

	keep if !mi(age_fixed, urban, edu_3_self, d_married, 						///
			    k_03, k_46, k_717, totalnumberchildren, 						///
				index_distress, z_distress)
				
*--------------------------------------------------
* Final sample selection: Age selection				 						     
*--------------------------------------------------
	
	keep if age_fixed>17 & age_fixed<65 // we lose a large portion of the sample - can we allow for older ages?
	
*--------------------------------------------------
* Not balanced panel: PRE + another time point (either DURING or POST) 				 						     
*--------------------------------------------------

	drop if mi(change_work12) & mi(change_work13)
	drop if mi(hh_12) & mi(hh_13)
	
*--------------------------------------------------
* Save dataset for analysis				 						     
*--------------------------------------------------	

	save "$data/cope_housework_FINAL", replace  

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*

*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	 COUPLE-LEVEL VARIABLES 			 			   	   *
*------------------------------------------------------------------------------*
	
*--------------------------------------------------
* Select work folders 						 						     
*-------------------------------------------------- 

 "INSERT YOUR WORKING FOLDER PATH"


global code			"$housework/Analyses"
global data			"$housework/Data"
global output 		"$housework/Output"

global w12 	 	 "$data\UKHLS12\6614stata_961F73F240850C31685A64327005C005F22A54B671C5F82433DEA980DDFE4CA1_V1\UKDA-6614-stata\stata\stata13_se\ukhls"
global cov19 	 "$data\covid19"

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 

u "$data/cope_housework_clean5.dta", clear
	
*--------------------------------------------------
* Create/check couple-level variables					 						     
*--------------------------------------------------

* check heterosexual
	ge het=female-p_female
	drop if het==0 // 34 observations
	
* check if same n. children for partners 
	bys hidp: ge k_actual=.
	replace k_actual=1 if kids03==p_kids03 & kids46==p_kids46 & kids717==p_kids717 
	egen kkids03=rowmax(kids03 p_kids03)
	egen kkids46=rowmax(kids46 p_kids46)
	egen kkids717=rowmax(kids717 p_kids717)
	
	* generate dummies
	ge k_03=1 if kkids03>0 & !mi(kkids03)
	replace k_03=0 if kkids03==0
	ge k_46=1 if kkids46>0 & !mi(kkids46)
	replace k_46=0 if kkids46==0
	ge k_717=1 if kkids717>0 & !mi(kkids717)
	replace k_717=0 if kkids717==0
	drop kk*
	
* housework (construct relative measure from absolute one)
	
	foreach time in pre during post {
		ge hh_`time'_1=hh_`time'_self/(hh_`time'_self+p_hh_`time'_self)
		ge hh_`time'=.
		replace hh_`time'=1 if hh_`time'_1==0 // all partner
		replace hh_`time'=2 if hh_`time'_1>0 & hh_`time'_1<=.4 // mostly partner
		replace hh_`time'=3 if hh_`time'_1>.4 & hh_`time'_1<.6 // equally
		replace hh_`time'=4 if hh_`time'_1>=.6 & hh_`time'_1<1 // mostly me
		replace hh_`time'=5 if hh_`time'_1==1 // entirely me
	}
	
	mdesc hh_pre hh_during hh_post
	count if !mi(hh_pre, hh_during, hh_post)
		
* variable capturing changes

	* PRE > LOCKDOWN 
	
	ge hh_12=.
	replace hh_12=1 if hh_pre>hh_during & !mi(hh_pre, hh_during)
	replace hh_12=2 if hh_pre==hh_during & !mi(hh_pre, hh_during)
	replace hh_12=3 if hh_pre<hh_during & !mi(hh_pre, hh_during)
	
	* PRE > POST
	
	ge hh_13=.
	replace hh_13=1 if hh_pre>hh_post & !mi(hh_pre, hh_post)
	replace hh_13=2 if hh_pre==hh_post & !mi(hh_pre, hh_post)
	replace hh_13=3 if hh_pre<hh_post & !mi(hh_pre, hh_post)

	la def any 1 "Decrease" 2 "No change" 3 "Increase"
	la val hh_12 any
	la val hh_13 any
	
*--------------------------------------------------
* Save dataset for analysis				 						     
*--------------------------------------------------	

	save "$data/cope_housework_clean6", replace  

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*

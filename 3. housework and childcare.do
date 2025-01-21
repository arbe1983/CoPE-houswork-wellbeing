*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	  HOUSEWORK & CHILDCARE 			 			   	   *
*------------------------------------------------------------------------------*

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
* Open dataset				 						     
*-------------------------------------------------- 

u "$data/cope_housework_clean1.dta", clear

*--------------------------------------------------
* Time points				 						     
*-------------------------------------------------- 

* PRE: January/February 2020 (retrospective info in COVID survey) or before
* specifically January 2019 to February 2020 (UKHLS waves 10/11/12)  

	global pre "intyear==2020 & intmonth<=2 | intyear<2020 & intyear>2018"

* LOCKDOWN: April+May 2020 (COVID survey + UKHLS waves 10/11/12) 

	global lock "intyear==2020 & intmonth==4 | intyear==2020 & intmonth==5"

* POST: from November 2020 until May 2022 (COVID survey + UKHLS waves 11/12)

	global post "intyear==2020 & intmonth>8 | intyear>2020"

*--------------------------------------------------
* Main X: housework and childcare (individual-level)					 						     
*-------------------------------------------------- 

* PRE

	* housework 
	
	su howlng 
	replace howlng=. if howlng<0 
	su howlng, det 
	return list
	replace howlng=r(p99) if howlng>r(p99) & !mi(howlng)
	mdesc howlng if $pre // 56.15%
	
	clonevar hh_pre_self=howlng if $pre
	bys pidp: egen hh_pre_self_TOT1=max(hh_pre_self)
	replace hh_pre_self=hh_pre_self_TOT1 if mi(hh_pre_self) & !mi(hh_pre_self_TOT1)
	drop hh_pre_self_TOT*
	mdesc hh_pre_self if $pre // 44.67%
		
* LOCKDOWN 

	* housework 
	
	su howlng_cv 
	replace howlng_cv=. if howlng_cv<0 
	su howlng_cv, det 
	return list
	replace howlng_cv=r(p99) if howlng_cv>r(p99) & !mi(howlng_cv) 
	mdesc howlng_cv if $lock // 21.36%
	
	clonevar hh_during_self=howlng_cv if $lock
	bys pidp: egen hh_during_self_TOT=max(hh_during_self)
	bys pidp: replace hh_during_self=hh_during_self_TOT if mi(hh_during_self) & !mi(hh_during_self_TOT)
	drop hh_during_self_TOT
	mdesc hh_during_self if $lock // 10.85%
	
* POST

	* housework 
	
	clonevar hh_post_self=howlng if $post
	bys pidp: egen hh_post_self_TOT1=max(hh_post_self)
	replace hh_post_self=hh_post_self_TOT1 if mi(hh_post_self) & !mi(hh_post_self_TOT1)
	drop hh_post_self_TOT*
	mdesc hh_post_self if $post // 46.23%
	
	mdesc howlng_cv if $post // 82.95%
	clonevar hh_post_self_retr=howlng_cv if $post
	bys pidp: egen hh_post_self_retr_TOT=max(hh_post_self_retr)
	bys pidp: replace hh_post_self=hh_post_self_retr_TOT if mi(hh_post_self) & !mi(hh_post_self_retr_TOT)
	drop hh_post_self_retr_TOT
	mdesc hh_post_self if $post // 10.14%
	
*--------------------------------------------------
* Save cleaned dataset					 						     
*-------------------------------------------------- 

save "$data/cope_housework_clean2", replace

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*

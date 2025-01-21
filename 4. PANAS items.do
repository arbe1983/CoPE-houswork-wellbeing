*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	  		PANAS ITEMS 			 			   		   *
*------------------------------------------------------------------------------*
	
*--------------------------------------------------
* Select work folders 						 						     
*-------------------------------------------------- 

*Anna Z.		
if "`c(username)'" == "annaz" {
	global housework "G:\Il Mio Drive\Housework-Distress paper (COPE)"
}

*Marija		
if "`c(username)'" == "MARIJA INSERT YOUR LAPTOP USERNAME" {
	global housework "MARIJA INSERT YOUR WORKING FOLDER PATH"
}

global code			"$housework/Analyses"
global data			"$housework/Data"
global output 		"$housework/Output"

global w12 	 	 "$data\UKHLS12\6614stata_961F73F240850C31685A64327005C005F22A54B671C5F82433DEA980DDFE4CA1_V1\UKDA-6614-stata\stata\stata13_se\ukhls"
global cov19 	 "$data\covid19"

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 

u "$data/cope_housework_clean2.dta", clear

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
* PANAS items/index				 						     
*--------------------------------------------------

* original variables
	
	fre scsf6a if $post // Last 4 weeks: Felt calm and peaceful - from "all of the time" to "none of the time"
	rename scsf6a calm
	replace calm=. if calm<1
	bys intyear intmonth: su calm if $post
	// very little over-time change. slight reduction in June, September, December-January. months from March 2022 onwards unreliable due to very few cases

	fre scsf6b if $post // Last 4 weeks: Had a lot of energy - from "all of the time" to "none of the time"
	rename scsf6b energy
	replace energy=. if energy<1
	bys intyear intmonth: su energy if $post
	// very little over-time change. slight reduction in April. slight increase in January-February. months from March 2022 onwards unreliable due to very few cases
	
	fre scsf6c if $post // Last 4 weeks: Felt downhearted and depressed - from "all of the time" to "none of the time"
	rename scsf6c depressed
	replace depressed=. if depressed<1
	replace depressed=6-depressed // to rescale it: higher values mean more depressed
	la def depressed 1 "None of the time" 2 "Most of the time" 3 "Some of the time" 4 "A little of the time" 5 "All of the time"
	la val depressed depressed
	bys intyear intmonth: su depressed if $post
	// very little over-time change. months from March 2022 onwards unreliable due to very few cases
	
	* standardized version of depression
	egen z_depressed=std(depressed) if $post
	bys pidp: egen z_depressed_TOT=max(z_depressed)
	replace z_depressed=z_depressed_TOT if mi(z_depressed) & !mi(z_depressed_TOT)
	drop z_depressed_TOT

* additive index 
	
	ge index_distress=calm+energy+depressed if $post
	su index_distress calm energy depressed if $post
	alpha calm energy depressed if $post
	
	bys pidp: egen index_distress_TOT=max(index_distress)
	replace index_distress=index_distress_TOT if mi(index_distress) & !mi(index_distress_TOT)
	drop index_distress_TOT
	
* PCA 
	
	pca calm energy depressed if $post
	
	pca calm energy depressed if $post, comp(3) 
	predict score if $post, center 
	su score if $post
	
* standardized index
* [the following syntax lines have to be run altogether for macros to work]

	ge z_distress=.
	
	su index_distress if female==0 & $post
	local mean_m=r(mean) 
	local sd_m=r(sd) 
	ge z_distress_men=. 
	replace z_distress_men=(index_distress-`mean_m')/`sd_m' if female==0 & $post
	
	su index_distress if female==1 & $post
	local mean_f=r(mean) 
	local sd_f=r(sd) 
	ge z_distress_women=. 
	replace z_distress_women=(index_distress-`mean_f')/`sd_f' if female==1 & $post
	
	replace z_distress=z_distress_men if female==0 & $post
	replace z_distress=z_distress_women if female==1 & $post
	
	bys pidp: egen z_distress_TOT=max(z_distress)
	replace z_distress=z_distress_TOT if mi(z_distress) & !mi(z_distress_TOT)
	drop z_distress_TOT

	su z_distress z_distress_men z_distress_women if $post

*--------------------------------------------------
* Save cleaned dataset					 						     
*-------------------------------------------------- 
	
save "$data/cope_housework_clean3", replace

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*
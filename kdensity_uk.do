*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	 DESCRIPTIVE STATISTICS			 			   	  	   *
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

version 16

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 

	u "$data/cope_housework_FINAL", clear

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 
		
	egen median_m = median(index_distress) if female==0
	egen median_f = median(index_distress) if female==1
	ge y0=0
	ge y1=.14
	
	two kdensity index_distress if female==0, bw(2) recast(area) col(black%50)  ///
		|| kdensity index_distress if female==1, bw(2) recast(area) col(black%20) ///
		tit(UK, size(huge) margin(b=5)) 										///
		xtit(Distress index (unstandardized), margin(t=3)) xla(3(1)15)			///
		ytit(Probability density, margin(r=3)) yla(0(.02).14) 					///
		|| rspike y0 y1 median_m, lcol("70 70 70")  							///
		|| rspike y0 y1 median_f, lcol("90 90 90") lpattern(shortdash)			///
		legend(order(1 "Men" 2 "Women" 3 "Median men" 4 "Median women") pos(1) ring(0) col(1) size(small))	   				
	
	gr export "$output/kdensity_uk.png", as(png) replace
	gr save "$output/kdensity_uk.gph", replace

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*
*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				Finland Syntax - Varhaiskasvatus - Ariane Bertogg			   *
*					  	 DESCRIPTIVE STATISTICS			 			   	  	   *
*------------------------------------------------------------------------------*
	

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 

	u "C:\xxx\analyticalfile_hwpaper_v5.dta", clear

set scheme s1mono
graph set window fontface "Arial"

	egen median_m = median(index_distress) if nomiss==1&hetero==1&age>17&age<65&female==0
	egen median_f = median(index_distress) if nomiss==1&hetero==1&age>17&age<65&female==1
	ge y0=0
	ge y1=.14
	
	two kdensity index_distress if nomiss==1&hetero==1&age>17&age<65&female==0, bw(2) recast(area) col(black%50)  ///
		|| kdensity index_distress if nomiss==1&hetero==1&age>17&age<65&female==1, bw(2) recast(area) col(black%20) ///
		tit(Finland, size(huge) margin(b=5)) 										///
		xtit(Distress index (unstandardized), margin(t=3)) xla(5(3)29)			///
		ytit(Probability density, margin(r=3)) yla(0(.02).14) 					///
		|| rspike y0 y1 median_m, lcol("70 70 70")  							///
		|| rspike y0 y1 median_f, lcol("90 90 90") lpattern(shortdash)			///
		legend(order(1 "Men" 2 "Women" 3 "Median men" 4 "Median women") pos(1) ring(0) col(1) size(small))	   				
	
	gr export "kdensity_fi.png", as(png) replace
	gr save "kdensity_fi.gph", replace

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*
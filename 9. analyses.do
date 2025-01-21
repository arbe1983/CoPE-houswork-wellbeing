*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	 		 ANALYSES			 			   	  		   *
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

version 16

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 

u "$data/cope_housework_FINAL", clear

*--------------------------------------------------
* Graphs general settings				 						     
*-------------------------------------------------- 

	set scheme s1mono  
	grstyle init
	gr set window fontface "Arial"
	
*--------------------------------------------------
* Sets of variables/controls			 						     
*-------------------------------------------------- 

	global controls_red i.female age_fixed i.edu_3_self i.urban
	global fam i.k_03 i.k_46 i.k_717 totalnumberchildren i.d_married 
	
*--------------------------------------------------
* Short-term			 						     
*-------------------------------------------------- 

	* ALL
	
	reg index_distress ib2.hh_12 i.change_work12 $controls_red $fam 
	est sto pooled_short

	reg index_distress ib2.hh_12##i.female i.change_work12 $controls_red $fam 
	est sto pooled_int_short
	
	* WOMEN

	reg z_distress ib2.hh_12 i.change_work12 $controls $fam if female==1
	est sto short_f
	
	* MEN
	
	reg z_distress ib2.hh_12 i.change_work12 $controls $fam if female==0
	est sto short_m
	
	* plot domestic > distress
	
	global opt xtit("Effect on Distress") 										///
			   xlab(-1(.2)1) xline(0, lc(black)) 								///
			   base leg(order(2 "Men" 4 "Women") row(1))

	coefplot short_m short_f, keep(*hh_12) 										///
			 $opt tit("Short-Term") 													
	gr save "$output/hh_short.gph", replace
	
*--------------------------------------------------
* Long-term			 						     
*-------------------------------------------------- 

	* ALL
	
	reg index_distress ib2.hh_13 i.change_work13 $controls_red $fam 
	est sto pooled_long

	reg index_distress ib2.hh_13##i.female i.change_work13 $controls_red $fam 
	est sto pooled_int_long
	
	* WOMEN

	reg z_distress ib2.hh_13 i.change_work13 $controls $fam if female==1
	est sto long_f
	
	* MEN
	
	reg z_distress ib2.hh_13 i.change_work13 $controls $fam if female==0
	est sto long_m
	
	* plot domestic > distress
	
	global opt xtit("Effect on Distress") 										///
			   xlab(-1(.2)1) xline(0, lc(black)) 								///
			   base leg(order(2 "Men" 4 "Women") row(1))

	coefplot long_m long_f, keep(*hh_13) 										///
			 $opt tit("Long-Term") 													
	gr save "$output/hh_long.gph", replace
	
*--------------------------------------------------
* Deliverables		 						     
*-------------------------------------------------- 
	
	* Table pooled models
	esttab pooled_short pooled_int_short pooled_long pooled_int_long 			///
		   using "$output/Pooled_UK (original scale).rtf", 						///
		   b(3) se nogap mti replace lab
	
	* Table models by gender
	esttab short_m long_m short_f long_f 										///
		   using "$output/Housework Effects - UK.rtf", 							///
		   b(3) nogap mti se lab replace
	
	* Graph comparison short/long-term effects 
	grc1leg "$output/hh_short.gph" "$output/hh_long.gph"
	gr save "$output/Multivariate - Housework (UK).gph", replace
	
*--------------------------------------------------
* Excel export 						     
*-------------------------------------------------- 

	cd "$output"
	
	* short, men
	est restore short_m
	margins hh_12
	mat houseshort_he1 = r(table)' 
	margins, dydx(hh_12)
	mat diff_houseshort_he1 = r(table)'

	* short, women
	est restore short_f
	margins hh_12
	mat houseshort_she1 = r(table)' 
	margins, dydx(hh_12)
	mat diff_houseshort_she1 = r(table)'

	* long, men
	est restore long_m
	margins hh_13
	mat houselong_he1 = r(table)'
	margins, dydx(hh_13)
	mat diff_houselong_he1 = r(table)'

	* long, women
	est restore long_f
	margins hh_13
	mat houselong_she1 = r(table)'
	margins, dydx(ib1.hh_13)
	mat diff_houselong_she1 = r(table)'
	
	putexcel set prediction_uk, sheet("UK - Housework", replace) replace
	putexcel B1="Probabilities" C1="SE" D1="Z" E1="P-value" F1="LB" G1="UB" 	///
			 A2=matrix(houseshort_he1) A7=matrix(houseshort_she1) 				///
			 A12=matrix(houselong_he1) A17=matrix(houselong_she1) 				///
			 A22=matrix(diff_houseshort_he1) A27=matrix(diff_houseshort_she1) 	///
			 A32=matrix(diff_houselong_he1) A37=matrix(diff_houselong_she1), 	///
			 rownames nformat(number_d2) 

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*
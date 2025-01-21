*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	 DESCRIPTIVE STATISTICS			 			   	  	   *
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
* Descriptives: overall			 						     
*--------------------------------------------------	
	
	asdoc sum index_distress z_distress i.hh_12 i.hh_13 						///
			  i.change_work12 i.change_work13 $controls $fam 					///
			  totalnumberchildren, 												///
			  tit(All) save(TableA1.rtf) replace

	asdoc sum index_distress z_distress i.hh_12 i.hh_13 						///
			  i.change_work12 i.change_work13 $controls $fam 					///
			  totalnumberchildren if female==0, 								///
			  tit(Men) save(TableA1.rtf) append 

	asdoc sum index_distress z_distress i.hh_12 i.hh_13 						///
			  i.change_work12 i.change_work13 $controls $fam 					///
			  totalnumberchildren if female==1, 								///
			  tit(Women) save(TableA1.rtf) append 
			  
*--------------------------------------------------
* Descriptives: changes in housework		 						     
*--------------------------------------------------	
	
	ta hh_12, ge(ch3_)
	ta hh_13, ge(chpp3_)
	la var ch3_1 "Decrease"
	la var chpp3_1 "Decrease"
	la var ch3_2 "No change"
	la var chpp3_2 "No change"
	la var ch3_3 "Increase"
	la var chpp3_3 "Increase"

	local collvars ch3_1 chpp3_1 ch3_2 chpp3_2 ch3_3 chpp3_3 index_distress z_distress

	collapse (mean) ch3_1 chpp3_1 ch3_2 chpp3_2 ch3_3 chpp3_3 index_distress 	///
					(sd) sd=index_distress (p5) p5=index_distress 				///
					(p95) p95=index_distress (p25) p25=index_distress 			///
					(p75) p75=index_distress (iqr) iqr=index_distress, by(female)
					
	ge country=4
	la def country 1"Finland" 2"Germany" 3"Netherlands" 4"UK", replace
	la val country country

* adjust name here *
save "$output/coll_uk_2024.dta", replace
export excel "$output/coll_uk_2024.xls", firstrow(variables) replace
	
*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*
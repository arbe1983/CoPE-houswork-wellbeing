*******************************************
*** Obtain Percentages for Descriptives ***
******************************************



* CoPE Project *
* Domestic Work & Distress Paper *
* Ariane Bertogg *

* September 2024 *
* Revision *


clear all
set more off
set maxvar 10000
set seed 42


	
***************
*** Prepare ***
***************

* USE THIS TO CREATE THE DESCRIPTIVE TABLE FOR THE APPENDIX (A.1) *

"C:\xxx\analyticalfile_hwpaper_v5.dta"

** Set the Controls **
global controls_red female age i.edu_3_self urban
global fam kids03 kids46 kids717 d_married totalnumberchildren


/* THis probably has been done from last time
*/


** Define the Analytical Sample **
* Finland *
drop nomiss*
mark nomiss_descriptives
markout nomiss_descriptives index_distress change_work12_new change_work13_new change_hh3 change_hh_prepost3 $controls_red $fam wave

ta nomiss_descriptives female
ta nomiss_descriptives female if wave==3


* DE and UK *
drop nomiss
mark nomiss_descriptives_short
markout nomiss_descriptives_short z_distress change_work12_new  change_hh3 $controls_red $fam wave

mark nomiss_descriptives_long
markout nomiss_descriptives_long z_distress change_work13_new  change_hh_prepost3 $controls_red $fam wave


* Create new markout variable that may be useful to identify valid cases for a potential "pooled" model *
mark nomiss_descriptives
markout nomiss_descriptives index_distress $controls_red $fam wave 
replace nomiss_descriptives==0 if change_hh3==.&change_work12_new==.
replace nomiss_descriptives=0 if change_hh_prepost3==.&change_work13_new==.
* (use also to z-standardize the DV only at the analytical sample) *

* Define Sample *
drop sample
ge sample=.
replace sample=1 if age>17&age<65&hetero==1&wave==3&partnered==1




**********************
*** Summary Tables ***
**********************

* only needed for UK if valid cases have change with the new housework variable *

*** (Finland Version with Balanced Panel) ***
* (Nomiss descriptives globally, as we have a balanced panel) *
asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&hetero==1&age>17&age<65&nomiss_descriptives==1, title(All) save(Summary Table.rtf) replace

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&hetero==1&age>17&age<65&female==0&nomiss_descriptives==1, title(Men) append 

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&hetero==1&age>17&age<65&female==1&nomiss_descriptives==1 , title(Women) append 



*** (Germany & UK - Unbalanced Panel) ***
* Case Numbers: Short-Term *
asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&hetero==1&age>17&age<65&nomiss_descriptives_short==1, title(All - Short) save(Summary Table_Short.rtf) replace

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&nomiss==1&hetero==1&age>17&age<65&female==0&nomiss_descriptives_short==1, title(Men - Short) append 

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&nomiss==1&hetero==1&age>17&age<65&female==1&nomiss_descriptives_short==1 , title(Women - Short) append 


* Case Numbers: Long-Term *
asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&hetero==1&age>17&age<65&nomiss_descriptives_long==1, title(All - Long) save(Summary Table_Long.rtf) replace

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&nomiss==1&hetero==1&age>17&age<65&female==0&nomiss_descriptives_long==1, title(Men - Long)append 

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls_red $fam if wave==3&nomiss==1&hetero==1&age>17&age<65&female==1&nomiss_descriptives_long==1 , title(Women - Long) append 





******************************************
*** Collapsed File for Box Plots of DV ***
******************************************

* USE THIS FILE TO CREATED YOUR COLLAPSED FILE - CHANGE COUNTRY NAME *

/* choose your own file 
use "C:\Users\arian\OneDrive\Desktop\DATA in use\Finland - August 2023\Finland - August 2023\Housework and Mental Health Paper\analyticalfile_hwpaper_v5.dta"
*/


* Prepare the categorical variables *
ta change_hh3, ge(ch3_)
ta change_hh_prepost3, ge(chpp3_)
lab var ch3_1 "Decrease"
lab var chpp3_1 "Decrease"
lab var ch3_2 "No change"
lab var chpp3_2 "No change"
lab var ch3_3 "Increase"
lab var chpp3_3 "Increase"

local collvars ch3_1 chpp3_1 ch3_2 chpp3_2 ch3_3 chpp3_3 index_distress z_distress

collapse (mean) ch3_1 chpp3_1 ch3_2 chpp3_2 ch3_3 chpp3_3 if wave==3&nomiss==1&hetero==1&age>17&age<65, by(female) 


* adjust number here: Finland=1, Germany=2 etc (see below) *
ge country=1
lab define country 1"Finland" 2"Germany" 3"Netherlands" 4"UK", replace
lab val country country

* adjust name here *
save coll_finland_2024.dta, replace
export excel coll_finland_2024.xls, firstrow(variables) replace

* ENDS HERE *




*****************************
*** Put together graphs ***
****************************

* (for Ariane only) *

* working globals  
	global work  	 "C:\Users\arian\Nextcloud\CoPE\PAPER VI - Housework and Wellbeing\R1 Acta"
	global data  	 "$work\for csv file production (UK new results)"
	global figures 	 "$work\new figures"

	
* Convert xls into dta *
import excel "$data\coll_germany_2024", first
save coll_germany_2024.dta, replace
clear

import excel "$data\coll_uk_2024", first
save coll_uk_2024.dta, replace
clear 

import excel "$data\coll_finland_2024", first
save coll_finland_2024.dta, replace
clear 


* Pool the files *
use "$data\coll_germany_2024"
drop country
ge country="Germany"
save, replace
clear 

use "$data\coll_uk_2024"
drop country
ge country="United Kingdom"
save, replace
clear 

use "$data\coll_finland_2024"
drop country
ge country="Finland"
append using "$data\coll_germany_2024", force
append using "$data\coll_uk_2024", force
save "$data\allcountries_2024.dta", replace



*** Now prepared to make the graphs ***
set scheme s1mono
graph set window fontface "Arial"

lab define female 0"Man" 1"Woman", replace
lab val female female

gen Country=1 if country=="Finland"
replace Country=2 if country=="Germany"
replace Country=3 if country=="United Kingdom"


* Use a loop *
forvalues i = 2/3 {
gr hbar ch3_1 ch3_2 ch3_3 if Country == `i', over(female) stack title("Short-Term")
gr save short_`i'.gph, replace
gr hbar chpp3_1 chpp3_2 chpp3_3 if Country == `i', over(female) stack title("Longer-Term")
gr save long_`i'.gph, replace
grc1leg short_`i'.gph long_`i'.gph, title("`i'") col(1)
gr save country_`i'.gph, replace
}

grc1leg country_1.gph country_2.gph country_3.gph, col(3)
gr save Figure2_2024.gph, replace




***********
*** End ***
***********




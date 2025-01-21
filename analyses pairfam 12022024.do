*-----------------------------*
*  Domestic work and distress *
*         during the          *
*     COVID-19 emergency      *
*-----------------------------*
*    German case - Pairfam    *
*-----------------------------*
*        Winter 2024          *
*-----------------------------*

*Only Analyses here. Refer to previous file for full data cleaning: "distress analyses 11022024.do"
cd ""
use analytical_sample_11022024.dta, clear

*---------------------------*
* Export values for Ariane  *
*---------------------------*

*** Set Directory ***
cd ""


ta change_hh3, ge(ch3_)
ta change_hh_prepost3, ge(chpp3_)
lab var ch3_1 "Decrease"
lab var chpp3_1 "Decrease"
lab var ch3_2 "No change"
lab var chpp3_2 "No change"
lab var ch3_3 "Increase"
lab var chpp3_3 "Increase"

local collvars ch3_1 chpp3_1 ch3_2 chpp3_2 ch3_3 chpp3_3 index_distress z_distress

preserve
collapse (mean) ch3_1 chpp3_1 ch3_2 chpp3_2 ch3_3 chpp3_3 index_distress (sd) sd=index_distress (semean) se=index_distress  (p5) p5=index_distress (p95) p95=index_distress (p25) p25=index_distress (p75) p75=index_distress (iqr) iqr=index_distress, by(female) 


* adjust number here: Finland=1, Germany=2 etc (see below) *
ge country=2
lab define country 1"Finland" 2"Germany" 3"Netherlands" 4"UK", replace
lab val country country

* adjust name here *
save coll_germany_2024.dta, replace
export excel coll_germany_2024.xls, firstrow(variables) replace

restore


*******************************
*** Descriptive Statistics  ***
*******************************


* For Ariane: Got stuck here, not sure what needs to be exported for the table


set scheme s1mono

global controls female age i.edu_3_self urban
global fam kids03 kids46 kids717 d_married childmrd
 
*** Summary Tables ***

* DE and UK *

drop nomiss_descriptives*

mark nomiss_descriptives_short
markout nomiss_descriptives_short z_distress change_work12_new change_hh3 $controls $fam wave

mark nomiss_descriptives_long
markout nomiss_descriptives_long z_distress change_work13_new change_hh_prepost3 $controls $fam wave

* Case Numbers: Short-Term *
asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls $fam if nomiss_descriptives_short==1, title(All - Short) save(Summary Table_Short.rtf) replace

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls $fam  if nomiss_descriptives_short==1&female==0, title(Men - Short) append 

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls $fam  if nomiss_descriptives_short==1&female==1, title(Women - Short) append 


* Case Numbers: Long-Term *
asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls $fam if nomiss_descriptives_long==1, title(All - Long) save(Summary Table_Long.rtf) replace

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls $fam if  nomiss_descriptives_long==1&female==0, title(Men - Long)append 

asdoc sum index_distress z_distress i.change_hh3 i.change_hh_prepost3 i.change_work12_new i.change_work13_new  $controls $fam if nomiss_descriptives_long==1&female==1, title(Women - Long) append 




*-----------------------------------*
*             Models                *
*-----------------------------------*

global controls_red female age i.edu_3_self urban
global fam kids03 kids46 kids717 d_married childmrd


***********************************************************************************
* (1) Long-Term Effects of Short-Term Changes                                     *
* Changes in Housework (HH) and Childcare (CC) between Pre-Pandemic and Lockdown  *
***********************************************************************************

* Run this analysis on both parents and non-parents in couples *

*** Both Genders ***
regress index_distress ib2.change_hh3 i.change_work12_new $controls_red $fam
est sto pooled_short

regress index_distress ib2.change_hh3##i.female i.change_work12_new $controls_red $fam
est sto pooled_int_short


*** Women ***
* HH and CC Change: Separate only housework * 
qui regress z_distress ib2.change_hh3 i.change_work12_new $controls_red $fam if female==1
est sto female_m5e_new

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam if female==1
est sto female_m5f_new


*** Men ***
* HH and CC Change: Separate only housework *
qui regress z_distress ib2.change_hh3 i.change_work12_new $controls_red $fam  if female==0
est sto male_m5e_new

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam  if female==0
est sto male_m5f_new



*** Plots: Comparing Men and Women ***
* Plots with reduced categories of employment (avoid empty cells) *
coefplot male_m5e_new female_m5e_new, keep(*change_hh3) xtitle("Effect on Distress") xline(0) title("Short-Term") base
graph save hh_short.gph, replace

* With childcare control *
coefplot male_m5e_new male_m5f_new female_m5e_new female_m5f_new, keep(*change_hh3 *change_cc3) xtitle("Effect on Distress") xline(0) title("Short-Term") base
graph save hh_short_withcc.gph, replace



**********************************************************************************
* (2) Long-Term Effects of Long-Term Changes                                     *
* Changes in Housework (HH) and Childcare (CC) between Pre-Pandemic and Lockdown *
**********************************************************************************


*** Both Genders ***
qui regress index_distress ib2.change_hh_prepost3 i.change_work12_new $controls_red $fam
est sto pooled_long

qui regress index_distress ib2.change_hh_prepost3##i.female i.change_work12_new $controls_red $fam
est sto pooled_int_long


*** Women ***
* HH and CC Change: Separate, only housework * 
qui regress z_distress ib2.change_hh_prepost3 i.change_work13_new $controls_red $fam if female==1
est sto female_m6e_new

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam if female==1
est sto female_m6f_new


*** Men ***
* HH and CC Change: Separate, only housework *
qui regress z_distress ib2.change_hh_prepost3 i.change_work13_new $controls_red $fam  if female==0
est sto male_m6e_new

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam  if female==0
est sto male_m6f_new


*** Plots: Comparing Men and Women ***
* Combined Housework Variable: Full Models *
coefplot male_m6e_new female_m6e_new, keep(*change_hh_prepost3) xtitle("Effect on Distress") xline(0) title("Long-Term") base
graph save hh_long.gph, replace

* With childcare control *
coefplot male_m6e_new male_m6f_new female_m6e_new female_m6f_new, keep(*change_hh_prepost3 *change_cc_prepost3) xtitle("Effect on Distress") xline(0) title("Long-Term") base
graph save hh_long_withcc.gph, replace
* no massive changes *



*** Deliverables ***

*** Tables: Pooled Models ***
esttab pooled_short pooled_int_short pooled_long pooled_int_long using "Pooled_Germany (original scale).rtf", b(3) se nogap mti replace lab

*** Comparing Short- and Long-Term Effects ***
grc1leg hh_short.gph hh_long.gph
gr save "Multivariate - Housework (Finland).gph", replace

esttab male_m5e_new male_m6e_new female_m5e_new female_m6e_new using "Housework Effects - Germany.rtf", b(3) nogap mti se lab replace




**************************
*** Robustness Checks ***
**************************

*** Controlling for Childcare ***
** On Entire Sample **
* Short *
qui regress z_distress ib2.change_hh3 ib2.change_cc3_rob i.change_work12_new $controls_red $fam  if female==0
est sto male_m7f_new

qui regress z_distress ib2.change_hh3 ib2.change_cc3_rob i.change_work12_new $controls_red $fam  if female==1
est sto female_m7f_new

* Long *
qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3_rob i.change_work13_new $controls_red $fam  if female==0
est sto male_m8f_new

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3_rob i.change_work13_new $controls_red $fam  if female==1
est sto female_m8f_new


* On Parent Sample *
* Short *
qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam  if childmrd>0&female==0
est sto fathers_m9f_new

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam  if childmrd>0&female==1
est sto mothers_m9f_new

* Long *
qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam  if childmrd>0&female==0
est sto fathers_m10f_new

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam  if childmrd>0&female==1
est sto mothers_m10f_new



*** Joint Variable: Housework and Childcare ***
ge any_inc5=any_increase5
* On Parent Sample *
qui regress z_distress ib1.any_inc5 i.change_work12_new $controls_red $fam  if childmrd>0&female==0
est sto fathers_m11f_new

qui regress z_distress ib1.any_inc5 i.change_work12_new $controls_red $fam  if childmrd>0&female==1
est sto mothers_m11f_new

* Long *
qui regress z_distress ib1.any_incpp5 i.change_work13_new $controls_red $fam  if childmrd>0&female==0
est sto fathers_m12f_new

qui regress z_distress  ib1.any_incpp5 i.change_work13_new $controls_red $fam  if childmrd>0&female==1
est sto mothers_m12f_new


esttab male_m7f_new fathers_m9f_new fathers_m11f_new female_m7f_new mothers_m9f_new mothers_m11f_new using "Table A.6c Germany.rtf", b(3) se nogap mti replace

esttab male_m8f_new fathers_m10f_new fathers_m12f_new female_m8f_new mothers_m10f_new mothers_m12f_new using "Table A.6d Germany.rtf", b(3) se nogap mti replace




************************
*** Export to Excel ***
************************



** Short-Term Changes **
* Men *
est restore male_m5e_new
margins change_hh3
mat houseshort_he1 = r(table)' 
margins, dydx(change_hh3)
mat diff_houseshort_he1 = r(table)'


* Women *
est restore female_m5e_new
margins change_hh3
mat houseshort_she1 = r(table)' 
margins, dydx(change_hh3)
mat diff_houseshort_she1 = r(table)'


** Long-Term Changes **
* Men *
est restore male_m6e_new
margins change_hh_prepost3
mat houselong_he1 = r(table)'
margins, dydx(change_hh_prepost3)
mat diff_houselong_he1 = r(table)'


* Women *
est restore female_m6e_new
margins change_hh_prepost3
mat houselong_she1 = r(table)'
margins, dydx(ib1.change_hh_prepost3)
mat diff_houselong_she1 = r(table)'



** Put to Excel **
* change country name *
putexcel set prediction_germany, sheet("Germany - Housework", replace) replace

putexcel B1="Probabilities" C1="SE" D1="Z" E1="P-value" F1="LB" G1="UB"  A2=matrix(houseshort_he1) A7=matrix(houseshort_she1) A12=matrix(houselong_he1) A17=matrix(houselong_she1) A22=matrix(diff_houseshort_he1) A27=matrix(diff_houseshort_she1) A32=matrix(diff_houselong_he1) A37=matrix(diff_houselong_she1), rownames nformat(number_d2) 

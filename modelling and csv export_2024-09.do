*********************************************
**** Housework Changes and Mental Health ***
*********************************************

* CoPE Project *
* Analysis of the Finnish Data *
* by Ariane Bertogg *
* September 2024 *
* Revision *



set more off
set maxvar 10000
set seed 42

/*Arianes path
use "C:\Users\xxx\analyticalfile_hwpaper_v5.dta"
*/




******************
*** Modelling ***
******************

* Please note the reduced controls WITHOUT migration *
global controls_red female age i.edu_3_self urban
global controls female age i.edu_3_self i.edu_3_part urban
global fam kids03 kids46 kids717 d_married totalnumberchildren

lab var selfrated_health "Selfrated health"
lab var health_issues "Health issues"


* NOTE: for UK need to change varname for change in housework *


**********************************************************************************
* (1) Long-Term Effects of Short-Term Changes *
* Changes in Housework (HH) and Childcare (CC) between Pre-Pandemic and Lockdown *
***********************************************************************************

* Run this analysis on both parents and non-parents in couples *


*** Women ***
* HH and CC Change: Separate only housework * 
qui regress z_distress ib2.change_hh3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto female_m5e_new

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto female_m5f_new


*** Men ***
* HH and CC Change: Separate only housework *
qui regress z_distress ib2.change_hh3 i.change_work12_new $controls_red $fam  if nomiss==1&age>17&age<65&female==0
est sto male_m5e_new

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam  if nomiss==1&age>17&age<65&female==0
est sto male_m5f_new



**********************************************************************************
* (2) Long-Term Effects of Long-Term Changes *
* Changes in Housework (HH) and Childcare (CC) between Pre-Pandemic and Lockdown *
*********************************************************************************
**


*** Women ***
* HH and CC Change: Separate, only housework * 
qui regress z_distress ib2.change_hh_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto female_m6e_new

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto female_m6f_new


*** Men ***
* HH and CC Change: Separate, only housework *
qui regress z_distress ib2.change_hh_prepost3 i.change_work13_new $controls_red $fam  if nomiss==1&age>17&age<65&female==0
est sto male_m6e_new

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam  if nomiss==1&age>17&age<65&female==0
est sto male_m6f_new



*********************
*** Deliverables ***
*********************

*** Tables: Pooled Models ***
esttab pooled_short pooled_int_short pooled_long pooled_int_long using "Pooled_Finland (original scale).rtf", b(3) se nogap mti replace lab

*** Comparing Short- and Long-Term Effects ***
grc1leg hh_short.gph hh_long.gph
gr save "Multivariate - Housework (Finland).gph", replace

esttab male_m5e_new male_m6e_new female_m5e_new female_m6e_new using "Housework Effects - Finland.rtf", b(3) nogap mti se lab replace




************************
*** Export to Excel ***
************************

*** Set Directory ***
* Change to your own * 
cd "C:\Users\arian\Nextcloud\CoPE\PAPER VI - Housework and Wellbeing\ARCHIVE\CSV Export for Graphing\Septmber 2024"


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
putexcel set prediction_finland, sheet("Finland - Housework", replace) replace

putexcel B1="Probabilities" C1="SE" D1="Z" E1="P-value" F1="LB" G1="UB"  A2=matrix(houseshort_he1) A7=matrix(houseshort_she1) A12=matrix(houselong_he1) A17=matrix(houselong_she1) A22=matrix(diff_houseshort_he1) A27=matrix(diff_houseshort_she1) A32=matrix(diff_houselong_he1) A37=matrix(diff_houselong_she1), rownames nformat(number_d2) 



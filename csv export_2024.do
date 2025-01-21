****************************************
*** Export Coefficients for Plotting ***
****************************************



* CoPE Project *
* Domestic Work & Distress Paper *
* Ariane Bertogg, based on code by Giulia Dotti Sani for Breadwinning Paper *

* December 2023 *



***************
*** Finland ***
***************

use "C:\Users\arian\OneDrive\Desktop\DATA in use\Finland - August 2023\Finland - August 2023\Housework and Mental Health Paper\analyticalfile_hwpaper_v4.dta"


ren z_distress z_distress_old

bysort female: egen mean_distress = mean(index_distress) if nomiss==1&hetero==1&age>20&age<55
bysort female: egen sd_distress = sd(index_distress) if nomiss==1&hetero==1&age>20&age<55
gen z_distress_new=.
replace z_distress_new=(index_distress-mean_distress)/sd_distress 

ren z_distress_new z_distress 



*** Modelling ***
* Main Models only *
* Change variable names if needed *

global controls_red female age i.edu_3_self urban
global controls female age i.edu_3_self i.edu_3_part migback urban
global fam kids03 kids46 kids717 d_married totalnumberchildren



** Short-Term Changes **
* Men *
qui regress z_distress i.any_increase5 i.change_work12_new $controls $fam  if nomiss==1&hetero==1&age>20&age<55&female==0
est sto male_m5e_new
margins any_increase5
mat domshort_he1 = r(table)' 
margins, dydx(any_increase5)
mat diff_domshort_he1 = r(table)'

est restore male_m5e_new
margins change_work12_new
mat workshort_he2 = r(table)'
margins, dydx(change_work12_new)
mat diff_workshort_he2 = r(table)'


* Women *
qui regress z_distress i.any_increase5 i.change_work12_new $controls $fam if nomiss==1&hetero==1&age>20&age<55&female==1
est sto female_m5e_new
margins any_increase5
mat domshort_she1 = r(table)' 
margins, dydx(any_increase5)
mat diff_domshort_she1 = r(table)'

est restore female_m5e_new
margins change_work12_new
mat workshort_she2 = r(table)'
margins, dydx(change_work12_new)
mat diff_workshort_she2 = r(table)'



** Long-Term Changes **
* Men *
qui regress z_distress i.any_incpp5 i.change_work13_new $controls $fam  if nomiss==1&hetero==1&age>20&age<55&female==0
est sto male_m6e_new
margins any_incpp5
mat domlong_he1 = r(table)'
margins, dydx(any_incpp5)
mat diff_domlong_he1 = r(table)'

est restore male_m6e_new
margins change_work13_new
mat worklong_he2 = r(table)'
margins, dydx(change_work13_new)
mat diff_worklong_he2 = r(table)'


* Women *
qui regress z_distress i.any_incpp5 i.change_work13_new $controls $fam if nomiss==1&hetero==1&age>20&age<55&female==1
est sto female_m6e_new
margins any_incpp5
mat domlong_she1 = r(table)'
margins, dydx(ib1.any_incpp5)
mat diff_domlong_she1 = r(table)'

est restore female_m6e_new
margins change_work13_new
mat worklong_she2 = r(table)'
margins, dydx(change_work13_new)
mat diff_worklong_she2 = r(table)'



*** Set Directory ***
* Change to your own * 
cd "C:\Users\arian\Nextcloud\CoPE\PAPER VI - Housework and Wellbeing\CSV Export for Graphing"


** Put to Excel **
* change country name *
putexcel set prediction_finland2, sheet("Finland - Domestic (Figure 2)", replace) replace

putexcel B1="Probabilities" C1="SE" D1="Z" E1="P-value" F1="LB" G1="UB"  A2=matrix(domshort_he1) A7=matrix(domshort_she1) A12=matrix(domlong_he1) A17=matrix(domlong_she1) A22=matrix(diff_domshort_he1) A27=matrix(diff_domshort_she1) A32=matrix(diff_domlong_he1) A37=matrix(diff_domlong_she1), rownames nformat(number_d2) 


putexcel set prediction_finland3, sheet("Finland - Employment (Figure 3)", replace) replace

putexcel B1="Probabilities" C1="SE" D1="Z" E1="P-value" F1="LB" G1="UB"  A2=matrix(workshort_he2) A7=matrix(workshort_she2) A12=matrix(worklong_he2) A17=matrix(worklong_she2) A22=matrix(diff_workshort_he2) A27=matrix(diff_workshort_she2) A32=matrix(diff_worklong_he2) A37=matrix(diff_worklong_she2), rownames nformat(number_d2) 


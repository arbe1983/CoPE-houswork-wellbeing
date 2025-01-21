*******************************************
*** Obtain Percentages for Descriptives ***
******************************************



* CoPE Project *
* Domestic Work & Distress Paper *
* Ariane Bertogg *

* February 2024 *


clear all
set more off
set maxvar 10000
set seed 42


	
***************
*** Prepare ***
***************

* USE THIS TO CREATE THE DESCRIPTIVE TABLE FOR THE APPENDIX (A.1) *

"C:\Users\arian\Nextcloud\CoPE\PAPER VI - Housework and Wellbeing\Analyses - FINLAND\analyticalfile_hwpaper_v5.dta"

** Set the Controls **
global controls_red female age i.edu_3_self urban
global fam kids03 kids46 kids717 d_married totalnumberchildren


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


/* This may not be needed: I did this to adjust the DV (z-standardized at the analytical sample) to the new analytical smple (which is now comprised a bit differently since we kicked out migration status and partner's education')


*** Make sure that the index is standardized at the anaytical sample only ***

drop z_distress_old
ren z_distress z_distress_old
* (to be able to recover the "old" distress) *

drop mean_distress* sd_distress*

egen mean_distress_men=mean(index_distress) if female==0&nomiss_descriptives==1&sample==1
egen mean_distress_women=mean(index_distress) if female==1&nomiss_descriptives==1&sample==1
egen sd_distress_men=sd(index_distress) if female==0&nomiss_descriptives==1&sample==1
egen sd_distress_women=sd(index_distress) if female==1&nomiss_descriptives==1&sample==1

sum mean_distress* sd_distress* 

gen z_distress_men=(index_distress-mean_distress_men)/sd_distress_men if female==0&nomiss_descriptives==1&sample==1
gen z_distress_women=(index_distress-mean_distress_women)/sd_distress_women if female==1&nomiss_descriptives==1&sample==1

gen z_distress=z_distress_men if female==0&sample==1&nomiss_descriptives==1
replace z_distress=z_distress_women if female==1&sample==1&nomiss_descriptives==1

sum z_distress*
bysort female: sum z_distress 

pwcorr z_distress index_distress if wave==3, sig
ta z_distress nomiss_descriptives if wave==3, m
* looks good *
*/



**********************
*** Summary Tables ***
**********************

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


** Until Here **




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

collapse (mean) ch3_1 chpp3_1 ch3_2 chpp3_2 ch3_3 chpp3_3 index_distress (sd) sd=index_distress (semean) se=index_distress (p5) p5=index_distress (p95) p95=index_distress (p25) p25=index_distress (p75) p75=index_distress (iqr) iqr=index_distress if wave==3&nomiss==1&hetero==1&age>17&age<65, by(female) 


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
	global work  	 "C:\Users\arian\Nextcloud\CoPE\PAPER VI - Housework and Wellbeing\CSV Export for Graphing"
	global data  	 "$work\data"
	global figures 	 "$work\figures"
	

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
append using "$data\coll_germany_2024"
append using "$data\coll_uk_2024"
save "$data\allcountries_2024.dta", replace



*** Now prepared to make the graphs ***
set scheme s1mono

lab define female 0"Man" 1"Woman"
lab val female female


* Use a loop *
forvalues i = 1/4 {
gr hbar ch3_1 ch3_2 ch3_3 if country == `i', over(female) stack title("Short-Term")
gr save short_`i'.gph, replace
gr hbar chpp3_1 chpp3_2 chpp3_3 if country == `i', over(female) stack title("Long-Term")
gr save long_`i'.gph, replace
grc1leg short_`i'.gph long_`i'.gph, title("`i'") col(1)
gr save country_`i'.gph, replace
}

grc1leg country_1.gph country_2.gph country_3.gph country_4.gph
gr save Figure2_2024.gph, replace

checking the values
sum index_distress lb ub p5 p95 sd

clonevar lqt=p25 
clonevar uqt=p75

ge lb=index_distress-(1.96*se)
ge ub=index_distress+(1.96*se)

clonevar mean=index_distress

forvalues i = 1/3 {
tw  rbar lqt mean female if female==0&Country == `i', fcolor(black%70) lc(black%90) horizontal barw(0.5) || rbar mean uqt female if female==0&Country == `i', fcolor(black%70) lc(black%90) horizontal barw(0.5) || rbar lqt mean female if female==1&Country == `i', fcolor(black%50) lc(black%70) horizontal barw(0.5) || rbar mean uqt female if female==1&Country == `i', fcolor(black%50) lc(black%70) horizontal barw(0.5) || rcap p5 p95 female if female==0&Country == `i', lc(black%90) horizontal || rcap p5 p95 female if female==1&Country == `i' , lc(black%70) horizontal ylab(0 "{bf:Men}" 1 "{bf:Women}") ytit("Gender") xtit("Index of Distress") lcol(gray%80) title("`i'") legend(off)
gr save index_`i'.gph, replace
}

* Combine the graphs * 
graph combine index_1.gph index_2.gph index_3.gph 
gr save "Figure1_2024 (with 5 and 95 pctile).gph", replace



forvalues i = 1/3 {
tw  rbar lqt mean female if female==0&Country == `i', fcolor(black%70) lc(black%90) horizontal barw(0.5) || rbar mean uqt female if female==0&Country == `i', fcolor(black%70) lc(black%90) horizontal barw(0.5) || rbar lqt mean female if female==1&Country == `i', fcolor(black%50) lc(black%70) horizontal barw(0.5) || rbar mean uqt female if female==1&Country == `i', fcolor(black%50) lc(black%70) horizontal barw(0.5) || rcap lb ub female if female==0&Country == `i', lc(black%90) horizontal || rcap lb ub female if female==1&Country == `i' , lc(black%90) horizontal ylab(0 "{bf:Men}" 1 "{bf:Women}") ytit("Gender") xtit("Index of Distress") lcol(gray%80) title("`i'") legend(off)
gr save index_`i'.gph, replace
}

* Combine the graphs * 
graph combine index_1.gph index_2.gph index_3.gph, col(1)
gr save "Figure1_2024 (CI).gph", replace




***********
*** End ***
***********
***************************
*** Robustness Analyses ***
***************************

* CoPE Project *
* Domestic Work & Distress Paper *
* Ariane Bertogg *

* February 2024 *


clear all
set more off
set maxvar 10000
set seed 42

use "C:\Users\arian\Nextcloud\CoPE\PAPER VI - Housework and Wellbeing\Analyses - FINLAND\analyticalfile_hwpaper_v5.dta"



*** Preparations ***

global controls_red female age i.edu_3_self urban
global controls female age i.edu_3_self i.edu_3_part urban
global fam kids03 kids46 kids717 d_married totalnumberchildren


** For bivariate effects: make sure that we use the same sample **

* Finland *
drop nomiss*
mark nomiss_descriptives
markout nomiss_descriptives z_distress change_work12_new change_work13_new change_hh3 change_hh_prepost3 $controls $fam wave

* DE and UK *
mark nomiss_descriptives_short
markout nomiss_descriptives z_distress change_work12_new  change_hh3 $controls $fam wave

mark nomiss_descriptives_long
markout nomiss_descriptives z_distress change_work13_new  change_hh_prepost3 $controls $fam wave


	
***************
*** Finland ***
***************

* First: adjust childcare change variable so have "non-parents" as a residual category (and not losing them *)

clonevar change_cc4=change_cc3
clonevar change_cc_prepost4=change_cc_prepost3

replace change_cc4=0 if change_cc3==.&totalnumberchildren==0

replace change_cc_prepost4=0 if change_cc_prepost3==.&totalnumberchildren==0


*** Women ***
* Housework Change: Bivariate * 
qui regress z_distress ib2.change_hh3 if nomiss==1&age>17&age<65&female==1
est sto female_bi_short

qui regress z_distress ib2.change_hh_prepost3 if nomiss==1&age>17&age<65&female==1
est sto female_bi_long

* Add control for childcare *
qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto female_cccontrol_short

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work1e_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto female_cccontrol_long


*** Men ***
* Housework Change: Bivariate * 
qui regress z_distress ib2.change_hh3 if nomiss==1&age>17&age<65&female==0
est sto male_bi_short

qui regress z_distress ib2.change_hh_prepost3 if nomiss==1&age>17&age<65&female==0
est sto male_bi_long

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==0
est sto male_cccontrol_short

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0
est sto male_cccontrol_long

esttab male_bi_short male_cccontrol_short female_bi_short female_cccontrol_short male_bi_long male_cccontrol_long female_bi_long female_cccontrol_long using "Table A.5 - Finland.rtf", b(3) nogap mti se replace



*** Only for the UK: Use parent-sample ***
* Women *
qui regress z_distress ib2.change_hh3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==1&totalnumberchildren>0
est sto mothers_short

qui regress z_distress ib2.change_hh_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1&totalnumberchildren>0
est sto mothers_long

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==1&totalnumberchildren>0
est sto mothers_cccontrol_short

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1&totalnumberchildren>0
est sto mothers_cccontrol_long

qui regress z_distress ib1.any_increase5 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1&totalnumberchildren>0
est sto mothers_joint_short

qui regress z_distress ib1.any_incpp5 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1&totalnumberchildren>0
est sto mothers_joint_long


* Men *
qui regress z_distress ib2.change_hh3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==0&totalnumberchildren>0
est sto fathers_short

qui regress z_distress ib2.change_hh_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0&totalnumberchildren>0
est sto fathers_long

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==0&totalnumberchildren>0
est sto fathers_cccontrol_short

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0&totalnumberchildren>0
est sto fathers_cccontrol_long

qui regress z_distress ib1.any_increase5 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0&totalnumberchildren>0
est sto fathers_joint_short

qui regress z_distress ib1.any_incpp5 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0&totalnumberchildren>0
est sto fathers_joint_long

esttab fathers_short father_cccontrol_short fathers_joint_short mothers_short mothers_cccontrol_short mothers_joint_short using "Table A.6_Parents_Short_UK.rtf", b(3) nogap mti se lab replace

esttab fathers_long father_cccontrol_long fathers_joint_long mothers_long mothers_cccontrol_long mothers_joint_long using "Table A.6_Parents_Long_UK.rtf", b(3) nogap mti se lab replace



** Bivariate Models and Control for Childcare: UK and Germany - Full Sample (Parents and Non-Parents) ***

* Women *
qui regress z_distress ib2.change_hh3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto women_short

qui regress z_distress ib2.change_hh_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto women_long

qui regress z_distress ib2.change_hh3 ib2.change_cc4 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto women_cccontrol_short

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost4 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto women_cccontrol_long

* This model is not necessarily needed for Germany, we have it from the old version *
qui regress z_distress ib1.any_increase5 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto women_joint_short

* This model is not necessarily needed for Germany, we have it from the old version *
qui regress z_distress ib1.any_incpp5 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==1
est sto women_joint_long


* Men *
qui regress z_distress ib2.change_hh3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==0
est sto men_short

qui regress z_distress ib2.change_hh_prepost3 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0
est sto men_long

qui regress z_distress ib2.change_hh3 ib2.change_cc3 i.change_work12_new $controls_red $fam if nomiss==1&age>17&age<65&female==0
est sto men_cccontrol_short

qui regress z_distress ib2.change_hh_prepost3 ib2.change_cc_prepost4 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0
est sto men_cccontrol_long

* This model is not necessarily needed for Germany, we have it from the old version *
qui regress z_distress ib1.any_increase5 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0
est sto men_joint_short

* This model is not necessarily needed for Germany, we have it from the old version *
qui regress z_distress ib1.any_incpp5 i.change_work13_new $controls_red $fam if nomiss==1&age>17&age<65&female==0
est sto men_joint_long

esttab men_short father_cccontrol_short men_joint_short women_short women_cccontrol_short women_joint_short using "Table A.6_All_Short_UK.rtf", b(3) nogap mti se lab replace

esttab men_long father_cccontrol_long men_joint_long women_long women_cccontrol_long women_joint_long using "Table A.6_All_Long_UK.rtf", b(3) nogap mti se lab replace

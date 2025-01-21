*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	   						   * 
*  FIGURES FOR PRESENTATION (Ariane Bertogg, based on Code by Anna Zamberlan()  *
*------------------------------------------------------------------------------*

	clear all
	set maxvar 10000

	* working globals  
	global work  	 "C:\Users\arian\Nextcloud\CoPE\PAPER VI - Housework and Wellbeing\CSV Export for Graphing"
	global data  	 "$work\January 2024"
	global figures 	 "$work\figures"
	
	* tables and graphs options 
	set scheme plotplain  
	grstyle init
	grstyle set plain, horizontal grid noextend
	grstyle set color white, : plotregion
	gr set window fontface "Times New Roman"

		
	
*---------------------------------------*
*            Domestic Work     			*
*---------------------------------------*
		
		
	// data import & cleaning
	clear 
	
	cd "$data"
	foreach file in "prediction_finland_adj" {
		local country=substr("`file'", 12, 11)
		clear all
		import excel using "`file'", firstrow
		rename A category
		rename Probabilities estimate
		rename SE se
		rename Pvalue p
		rename LB lb
		rename UB ub
		rename Z z
		drop H I J
		ge country="`country'"
		replace country="Finland" if country=="finland"
		replace country="Germany" if country=="germany"
		replace country="United Kingdom" if country=="uk"
		
		ge n=_n
		drop if mi(se)
				
		ge female=1 if (n==6|n==7|n==8|n==16|n==17|n==18|n==26|n==27|n==28|n==36|n==37|n==38)
		
		replace female=0 if (n==1|n==2|n==3|n==11|n==12|n==13|n==21|n==22|n==23|n==31|n==32|n==33)
		
		ge decrease=1 if (n==1|n==6|n==11|n==16|n==21|n==26|n==31|n==36)
		ge nochange=1 if (n==2|n==7|n==12|n==17|n==22|n==27|n==32|n==37)
		ge increase=1 if (n==3|n==8|n==13|n==18|n==23|n==28|n==33|n==38)
		
		recode n (1/18=1 "predicted probabilties") (21/38=2 "ame"), gen(f_estimate_type)
		ge estimate_type=""
		replace estimate_type="ame" if f_estimate_type==2
		replace estimate_type="prediction" if f_estimate_type==1
		
		recode n(1/8=1) (11/18=0) (21/29=1) (31/38=0), gen(short_term)
		lab define short_term 0"Long-term" 1"Short-term"
		lab val short_term short_term
		
		order country estimate estimate_type  decrease nochange increase female short_term  se p lb ub z
	
		save  "data_`country'.dta", replace
		
		ge female_pre=female
		replace female_pre=-0.25 if (n==1|n==11)&female==0
		replace female_pre=0.0 if (n==2|n==12)&female==0
		replace female_pre=0.25 if (n==3|n==13|n==25|n==30)&female==0 
		
		replace female_pre=0.75 if (n==6|n==16)&female==1
		replace female_pre=1 if (n==7|n==17)&female==1
		replace female_pre=1.125 if (n==8|n==18)&female==1
		
		ge female_ame=female
		replace female_ame=-0.25 if (n==21|n==31)&female==0
		replace female_ame=0 if (n==22|n==32)&female==0	
		replace female_ame=0.25 if (n==23|n==33)&female==0
		
		replace female_ame= 0.75 if (n==26|n==36)&female==1
		replace female_ame=1 if (n==27|n==37)&female==1
		replace female_ame=1.25 if (n==28|n==38)&female==1
		
		save, replace
		
	}
	
		
* AME: short-term	
tw scatter estimate female_ame if estimate_type=="ame" & short_term==1&female==0, msym(O) mc(black) mfc(black) msize(medium) || scatter estimate female_ame if estimate_type=="ame" & short_term==1&female==1, msym(T) mc(black%60) mfc(white) msize(medium) || rcap ub lb female_ame if estimate_type=="ame" & short_term==1&female==0, lc(black%50) || rcap ub lb female_ame if estimate_type=="ame" & short_term==1&female==1, lc(black%70)  xtit("By Gender") ytit("AME") yline(0) lcol(gray%80) title("Short-Term") xlabel(-0.25 "Decrease (ref.)" 0 "No change (ref.)"  0.25 "Increase" 0.75 "Decrease" 1 "No change (ref.)" 1.25 "Increase" 0.01"{bf:Men}" 1.01 "{bf:Women}") legend(off)
gr save "$work\figures/fig2_short_`country'.gph", replace
	
* AME: long-term
tw scatter estimate female_ame if estimate_type=="ame" & short_term==0&female==0, msym(O) mc(black) mfc(black) msize(medium) || scatter estimate female_ame if estimate_type=="ame" & short_term==0&female==1, msym(T) mc(black%60) mfc(white) msize(medium) || rcap ub lb female_ame if estimate_type=="ame" & short_term==0&female==0, lc(black%50) || rcap ub lb female_ame if estimate_type=="ame" & short_term==0&female==1, lc(black%70) xlab(0 "{bf:Men}" 1 "{bf:Women}") xtit("By Gender") ytit("AME") yline(0) lcol(gray%80) title("Long-Term") xlabel(-0.25 "Decrease (ref.)" 0 "No change (ref.)"  0.25 "Increase" 0.75 "Decrease" 1 "No change (ref.)" 1.25 "Increase" 0.01"{bf:Men}" 1.01 "{bf:Women}") legend(off)
gr save "$work\figures/fig2_long_`country'.gph", replace

graph combine "$work\figures/fig2_short_`country'.gph" "$work\figures/fig2_long_`country'.gph", title("`country'") col(1) 
gr save "$work\figures/fig2_`country'.gph", replace


* Predicted Probabilities instead of AME *
* short-term *				
tw scatter estimate female_pre if estimate_type=="prediction" & short_term==1&female==0, msym(O) mc(black) mfc(black) msize(medium) || scatter estimate female_pre if estimate_type=="prediction" & short_term==1&female==1, msym(T) mc(black%60) mfc(white) msize(medium) || rcap ub lb female_pre if estimate_type=="prediction" & short_term==1&female==0, lc(black%50) || rcap ub lb female_pre if estimate_type=="prediction" & short_term==1&female==1, lc(black%70) xlab(0 "{bf:Men}" 1 "{bf:Women}") xtit("") ytit("Predicted Probability") yline(0) lcol(gray%80) title("Short-Term") xlabel(-0.25 "Decrease (ref.)" 0 "No change (ref.)"  0.25 "Increase" 0.75 "Decrease" 1 "No change (ref.)" 1.25 "Increase") legend(off) 
gr save "$work\figures/pred_short_`country'.gph", replace
	
* long-term
tw scatter estimate female_pre if estimate_type=="prediction" & short_term==0&female==0, msym(O) mc(black) mfc(black) msize(medium) || scatter estimate female_pre if estimate_type=="prediction" & short_term==0&female==1, msym(T) mc(black%60) mfc(white) msize(medium) || rcap ub lb female_pre if estimate_type=="prediction" & short_term==0&female==0, lc(black%50) || rcap ub lb female_pre if estimate_type=="prediction" & short_term==0&female==1, lc(black%70) xlab(0 "{bf:Men}" 1 "{bf:Women}") xtit("") ytit("Predicted Probability") yline(0) lcol(gray%80) title("Long-Term") xlabel(-0.25 "Decrease (ref.)" 0 "No change (ref.)"  0.25 "Increase" 0.75 "Decrease" 1 "No change (ref.)" 1.25 "Increase") legend(off)
gr save "$work\figures/pred_long_`country'.gph", replace						
		
graph combine "$work\figures/pred_short_`country'.gph" "$work\figures/pred_long_`country'.gph", title("`country'") col(1) 
gr save "$work\figures/pred_`country'.gph", replace



* Short-and-Long in one graph! *
recode short_term (0=1) (1=0), gen (long_term)
ge shortlong_pre=.
replace shortlong_pre=-0.35 if (n==1|n==21)&long_term==0&female==0
replace shortlong_pre=-0.25 if (n==6|n==26)&long_term==0&female==1
replace shortlong_pre=-0.05 if (n==2|n==22)&long_term==0&female==0
replace shortlong_pre=0.05 if (n==7|n==27)&long_term==0&female==1
replace shortlong_pre=0.25 if (n==3|n==23)&long_term==0&female==0
replace shortlong_pre=0.35 if (n==8|n==28)&long_term==0&female==1

replace shortlong_pre=0.65 if (n==11|n==31)&long_term==1&female==0
replace shortlong_pre=0.75 if (n==16|n==36)&long_term==1&female==1
replace female_pre=0.95 if (n==12|n==32)&long_term==1&female==0
replace female_pre=1.05 if (n==17|n==37)&long_term==1&female==1
replace shortlong_pre=1.25 if (n==13|n==33)&long_term==1&female==0
replace shortlong_pre=1.35 if (n==18|n==38)&long_term==1&female==1

* Short-and-Long in one Figure! *
tw scatter estimate shortlong_pre if estimate_type=="prediction" & long_term==0&female==0, msym(O) mc(black) mfc(black) msize(medium) || scatter estimate shortlong_pre if estimate_type=="prediction" & long_term==0&female==1, msym(T) mc(black%70) mfc(white) msize(medium) || rcap ub lb shortlong_pre if estimate_type=="prediction" & long_term==0&female==0, lc(black%80) || rcap ub lb shortlong_pre if estimate_type=="prediction" & long_term==0&female==1, lc(black%50) || scatter estimate shortlong_pre if estimate_type=="prediction" & long_term==1&female==0, msym(O) mc(black) mfc(black) msize(medium) || scatter estimate shortlong_pre if estimate_type=="prediction" & long_term==1&female==1, msym(T) mc(black%70) mfc(white) msize(medium) || rcap ub lb shortlong_pre if estimate_type=="prediction" & long_term==1&female==0, lc(black%80) || rcap ub lb shortlong_pre if estimate_type=="prediction" & long_term==1&female==1, lc(black%50) xtit("") ytit("Predicted Probability") yline(0) lcol(gray%80) title("`country'") xlabel(-0.3 "Decrease" -0 "No change" 0.3"Increase" 0.7"Decrease" 1 "No change" 1.3 "Increase" 0.01 "{bf:Short-Term}" 1.01 "{bf:Long-term}") 

gr save "$work\figures/pred_shortlong_`country'.gph", replace								
		
		save graphingfile_`country'.dta, replace

	}
	

	
*---------------------------------------*
*           Final Graphs     			*
*---------------------------------------*
	
	grc1leg "$work\figures/fig2_Finland.gph" "$work\figures/fig2_Germany.gph" "$work\figures/fig2_United Kingdom.gph", col(2)
	gr save "$work\figures/ame_combined.gph", replace
	
	grc1leg "$work\figures/pred_Finland.gph" "$work\figures/pred_Germany.gph" "$work\figures/pred_United Kingdom.gph", col(2)
	gr save "$work\figures/predictive_combined.gph", replace
	
				
	grc1leg "$work\figures/fig3_Finland.gph" "$work\figures/fig3_Germany.gph" "$work\figures/fig3_United Kingdom.gph", col(2)
	gr save "$work\figures/empl_ame_combined.gph", replace
	
	grc1leg "$work\figures/empl_pred_Finland.gph" "$work\figures/empl_pred_Germany.gph" "$work\figures/pred_United Kingdom.gph", col(2)
	gr save "$work\figures/empl_predictive_combined.gph", replace
		
		
		
*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*
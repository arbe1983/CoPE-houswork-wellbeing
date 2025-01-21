*------------------------------------------------------------------------------*
*						CoPE PROJECT - HOUSEWORK	      					   *
*				UK SYNTAXES	(Anna Zamberlan & Marija Bashevska)				   *
*					  	TIME POINTS AND CONTROLS 			 			   	   *
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

global code			"$housework\Analyses"
global data			"$housework\Data"
global output 		"$housework\Output"

global w12 	 	 "$data\UKHLS12\6614stata_961F73F240850C31685A64327005C005F22A54B671C5F82433DEA980DDFE4CA1_V1\UKDA-6614-stata\stata\stata13_se\ukhls"
global cov19 	 "$data\covid19"

*--------------------------------------------------
* Open dataset				 						     
*-------------------------------------------------- 

u "$data/cope_housework.dta", clear

*--------------------------------------------------
* Time points selection				 						     
*-------------------------------------------------- 

* PRE: January/February 2020 (retrospective info in COVID survey) or before
* specifically January 2019 to February 2020 (UKHLS waves 10/11/12)  

	global pre "intyear==2020 & intmonth<=2 | intyear<2020 & intyear>2018"

* LOCKDOWN: April+May 2020 (COVID survey + UKHLS waves 10/11/12) 

	global lock "intyear==2020 & intmonth==4 | intyear==2020 & intmonth==5"

* POST: from November 2020 until May 2022 (COVID survey + UKHLS waves 11/12)

	global post "intyear==2020 & intmonth>8 | intyear>2020"
	
	keep if $pre | $lock | $post
	
*--------------------------------------------------
* Control variables					 						     
*-------------------------------------------------- 

* gender
	ge fem=.
	replace fem=0  if sex_dv==1 | sex==1
	replace fem=1  if sex_dv==2 | sex==2
	bys pidp: egen female=max(fem)
	
	la def female 0 "Men" 1 "Women", replace
	la val female female

* age
	replace age=dvage if dvage>0 & mi(age)
	bys pidp: ge age_pre=age if $pre // set age variable as the one observed in the pre-lockdown period (time invariant)
	bys pidp: egen age_fixed=max(age_pre) 
	bys pidp: replace age_fixed=age-1 if mi(age_pre, age_fixed) // if missing age info from $pre, replace with following observation and subtract 1 year
	bys pidp: egen age_fixed_min=min(age_fixed) // make sure that the age is fixed at the minimum observed value
	bys pidp: replace age_fixed=age_fixed_min
	drop age age_pre age_fixed_min
	*drop if age_fixed<20 | age_fixed>54 // age selection (TO BE CHECKED)
	
* migration background
	ge migr=.
	replace migr=1 if plbornc>=5 & !mi(plbornc) // from UKHLS 
	replace migr=0 if plbornc==-8
	bys pidp: egen migback=max(migr)
	mdesc migback // 2.05% missings due to don't know/refusal (cannot be retrieved)
	drop migr
	
* urban/rural
	replace urban_dv=. if urban_dv<1 // from UKHLS
	bys pidp: egen urban=max(urban_dv)
	recode urban (2=0)
	mdesc urban // 2.74% missings (cannot be retrieved because the info is missing in the COVID survey - thus, only ids interviewed also in previous waves can be kept)
	
	la def urban 0 "rural" 1 "urban" 
	la val urban urban 

* education
	recode hiqual_dv (1 2 = 3 "higher edu") (3 4 = 2 "medium edu") (5 9 = 1 "low edu") (else=.), ge(edu)
	bys pidp: egen edu_3_self=max(edu) // time invariant
	mdesc edu_3_self // 3.32% missings (cannot be retrieved because the info is missing in the COVID survey - thus, only ids interviewed also in previous waves can be kept)
	
* marital status 
	ge married=0 if mastat_dv>0
	replace married=1 if mastat_dv==2 
	bys pidp: egen d_married=max(married) // time invariant
	
	la def d_married 0 "not married" 1 "married" 
	la val d_married d_married 

* n children	
	
	* age of each school age child // in the COVID survey, info asked in the home schooling module
	rename childagea childage1
	rename childageb childage2
	rename childagec childage3
	rename childaged childage4
	rename childagee childage5
	rename childagef childage6
	rename childageg childage7
	rename childageh childage8
	rename childagei childage9
	rename childagej childage10
	
	forval y=1/10 {
		replace childage`y'=. if childage`y'<0
	}
		
	* n. children aged 0-3
	bys pidp: egen kids03=total((childage1>=0 & childage1<4)+					///
							   (childage2>=0 & childage2<4)+					///
							   (childage3>=0 & childage3<4)+					///
							   (childage4>=0 & childage4<4)+					///
							   (childage5>=0 & childage5<4)+					///
							   (childage6>=0 & childage6<4)+					///
							   (childage7>=0 & childage7<4)+					///
							   (childage8>=0 & childage8<4)+					///
							   (childage9>=0 & childage9<4)+					///
							   (childage10>=0 & childage10<4))
	
	* n. children aged 4-6
	bys pidp: egen kids46=total((childage1>3 & childage1<7)+					///
							   (childage2>3 & childage2<7)+						///
							   (childage3>3 & childage3<7)+						///
							   (childage4>3 & childage4<7)+						///
							   (childage5>3 & childage5<7)+						///
							   (childage6>3 & childage6<7)+						///
							   (childage7>3 & childage7<7)+						///
							   (childage8>3 & childage8<7)+						///
							   (childage9>3 & childage9<7)+						///
							   (childage10>3 & childage10<7))
	
	* n. children aged 7-17
	bys pidp: egen kids717=total((childage1>6 & childage1<18)+					///
							    (childage2>6 & childage2<18)+					///
							    (childage3>6 & childage3<18)+					///
							    (childage4>6 & childage4<18)+					///
							    (childage5>6 & childage5<18)+					///
							    (childage6>6 & childage6<18)+					///
							    (childage7>6 & childage7<18)+					///
							    (childage8>6 & childage8<18)+					///
							    (childage9>6 & childage9<18)+					///
							    (childage10>6 & childage10<18))
	
	* n. children aged 0-17
	bys pidp: egen totalnumberchildren=total((childage1>=0 & childage1<18)+		///
											(childage2>=0 & childage2<18)+		///
											(childage3>=0 & childage3<18)+		///
											(childage4>=0 & childage4<18)+		///
											(childage5>=0 & childage5<18)+		///
											(childage6>=0 & childage6<18)+		///
											(childage7>=0 & childage7<18)+		///
											(childage8>=0 & childage8<18)+		///
											(childage9>=0 & childage9<18)+		///
											(childage10>=0 & childage10<18)) 
	
	* if missing info on children in COVID survey, retrieve from UKHLS wave 12
	
	clonevar kk_03_RETR=nch02_dv // n. children aged 0-2 in hh (UKHLS w12) 
	bys pidp: replace kids03=kk_03_RETR if kids03==0 & kk_03_RETR !=0 & !mi(kk_03_RETR) 
	replace kids03=. if kids03<0
	drop kk_03_RETR
	
	clonevar kk_46_RETR=nch34_dv // n. children aged 3-4 in hh (UKHLS w12)
	bys pidp: replace kids46=kk_46_RETR if kids46==0 & kk_46_RETR !=0 & !mi(kk_46_RETR) 
	replace kids46=. if kids46<0
	drop kk_46_RETR
	
	clonevar kk_717_RETR=nkids615 // n. children aged 6-15 in hh (UKHLS w12)
	replace kk_717_RETR=n10to15 if mi(kk_717_RETR) & !mi(n10to15) // n. children aged 10-15 in hh (UKHLS w12) 
	replace kk_717_RETR=nch10to15 if mi(kk_717_RETR) & !mi(nch10to15) // n. children (bio or not) aged 10-15 in hh (UKHLS w12) 
	replace kk_717_RETR=nch1215_dv if mi(kk_717_RETR) & !mi(nch1215_dv) // n. children aged 12-15 in hh (UKHLS w12) 
	replace kk_717_RETR=hhcompb if mi(kk_717_RETR) & !mi(hhcompb) // n. hh members aged 5-15
	bys pidp: replace kids717=kk_717_RETR if kids717==0 & kk_717_RETR !=0 & !mi(kk_717_RETR) 
	replace kids717=. if kids717<0
	drop kk_717_RETR

	* assign n. children to all time points in which individuals are observed (time-invariant var)
	bys pidp: egen k_03=max(kids03)
	bys pidp: egen k_46=max(kids46)
	bys pidp: egen k_717=max(kids717)
	drop kids03 kids46 kids717
	rename k_03 kids03
	rename k_46 kids46
	rename k_717 kids717
	
	* check errors (no children)
	replace totalnumberchildren=0 if kids03==0 & kids46==0 & kids717==0
	
	/*
	* generate dummies
	replace kids03=1 if kids03>0 & !mi(kids03)
	replace kids46=1 if kids46>0 & !mi(kids46)
	replace kids717=1 if kids717>0 & !mi(kids717)
	*/
	
* employment

	* PRE
	recode blwork (1 2 3=1) (4=0) (else=.)  // employed/non-employed in Jan/Feb 2020 (PRE)
	bys pidp: egen blwork_TOT=max(blwork)
	rename blwork_TOT empl_PRE
	recode jbhas (1=1) (2=0) (else=.) // retrieve info for missing cases from the pre-lockdown period (UKHLS) (1)
	bys pidp: replace empl_PRE=jbhas if mi(empl_PRE) & !mi(jbhas) 
	bys pidp: egen empl_PRE_TOT1=max(empl_PRE)
	bys pidp: replace empl_PRE=empl_PRE_TOT1 if mi(empl_PRE) & !mi(empl_PRE_TOT1)
	recode employ (1=1) (2=0) (else=.) // retrieve info for missing cases from the pre-lockdown period (UKHLS) (2)
	bys pidp: replace empl_PRE=employ if mi(empl_PRE) & !mi(employ) & $pre
	bys pidp: egen empl_PRE_TOT2=max(empl_PRE)
	bys pidp: replace empl_PRE=empl_PRE_TOT2 if mi(empl_PRE) & !mi(empl_PRE_TOT2)
	drop empl_PRE_TOT*
	
	* LOCKDOWN
	recode sempderived (1 2 3=1) (4=0) (else=.) // employed/non-employed during COVID survey
	replace sempderived=. if intmonth <4 | intmonth==11 // exclude observations before April 2020 and after September 2020
	bys pidp: ge empl_LOCK=sempderived if $lock
	bys pidp: egen sempderived_TOT1=max(empl_LOCK)
	replace empl_LOCK=sempderived_TOT1
	replace empl_LOCK=sempderived if intmonth==9 & mi(empl_LOCK) // retrieve missings from September 2020
	bys pidp: egen sempderived_TOT2=max(empl_LOCK)
	replace empl_LOCK=sempderived_TOT2
	drop sempderived_TOT*
		
	* POST
	bys pidp: ge empl_POST=jbhas if $post
	bys pidp: egen empl_POST_TOT1=max(empl_POST)
	bys pidp: replace empl_POST=empl_POST_TOT1 if mi(empl_POST) & !mi(empl_POST_TOT1)
	bys pidp: replace empl_POST=employ if mi(empl_POST) & !mi(employ) & $post
	bys pidp: egen empl_POST_TOT2=max(empl_POST)
	bys pidp: replace empl_POST=empl_POST_TOT2 if mi(empl_POST) & !mi(empl_POST_TOT2)
	bys pidp: replace empl_POST=sempderived if mi(empl_POST) & !mi(sempderived) & $post
	bys pidp: egen empl_POST_TOT3=max(empl_POST)
	bys pidp: replace empl_POST=empl_POST_TOT3 if mi(empl_POST) & !mi(empl_POST_TOT3)
	drop empl_POST_TOT*
	
* working hours

	* PRE
	replace blhours=0 if blhours==-8 // hours worked in Jan/Feb 2020 (PRE)
	replace blhours=. if blhours<0
	su blhours, det 
	return list
	replace blhours=r(p99) if blhours>r(p99) & !mi(blhours)
	replace blhours=1 if blhours<1 & blhours!=0 & !mi(blhours)
	bys pidp: egen hours_PRE=max(blhours)
	replace jbhrs=0 if jbhrs==-8 // retrieve info for missing cases from the pre-lockdown period (UKHLS)
	replace jbhrs=. if jbhrs<0
	su jbhrs, det 
	return list
	replace jbhrs=r(p99) if jbhrs>r(p99) & !mi(jbhrs)
	replace jbhrs=1 if jbhrs<1 & jbhrs!=0 & !mi(jbhrs)
	bys pidp: egen jbhrs_PRE=max(jbhrs) 
	bys pidp: replace hours_PRE=jbhrs_PRE if mi(hours_PRE) & !mi(jbhrs_PRE) & $pre
	drop jbhrs_PRE
	bys pidp: egen hours_PRE_TOT=max(hours_PRE)
	drop hours_PRE
	rename hours_PRE_TOT hours_PRE
	
	ge parttime=. 
	replace parttime=1 if hours_PRE<35 & !mi(hours_PRE) // using the GOV.UK definition
	replace parttime=0 if hours_PRE>=35  & !mi(hours_PRE)
	rename parttime parttime_PRE
	replace parttime_PRE=3 if empl_PRE==0 // non-working
	
	* LOCKDOWN 
	replace hours=0 if hours<0
	su hours, det 
	return list
	replace hours=r(p99) if hours>r(p99) & !mi(hours) 
	replace hours=1 if hours<1 & hours!=0 & !mi(hours) 
	
	bys pidp: ge hours_LOCK=hours if $lock 
	bys pidp: egen hours_LOCK_TOT=max(hours_LOCK)
	bys pidp: replace hours_LOCK=hours_LOCK_TOT if mi(hours_LOCK) & !mi(hours_LOCK_TOT)
	drop hours_LOCK_TOT
	
	gen parttime_LOCK=. 
	replace parttime_LOCK=1 if hours_LOCK<35 & !mi(hours_LOCK) 
	replace parttime_LOCK=0 if hours_LOCK>=35 & !mi(hours_LOCK) 
	bys pidp: egen parttime_LOCK_TOT=max(parttime_LOCK)
	bys pidp: replace parttime_LOCK=parttime_LOCK_TOT if mi(parttime_LOCK) & !mi(parttime_LOCK_TOT)
	drop parttime_LOCK_TOT
	replace parttime_LOCK=3 if empl_LOCK==0 // non-working
	
	* POST 
	bys pidp: ge hours_POST=hours if $post 
	bys pidp: egen hours_POST_TOT=max(hours_POST)
	bys pidp: replace hours_POST=hours_POST_TOT if mi(hours_POST) & !mi(hours_POST_TOT)
	drop hours_POST_TOT
	
	gen parttime_POST=.  
	replace parttime_POST=1 if hours_POST<35 & !mi(hours_POST) 
	replace parttime_POST=0 if hours_POST>=35 & !mi(hours_POST) 
	bys pidp: egen parttime_POST_TOT=max(parttime_POST)
	bys pidp: replace parttime_POST=parttime_POST_TOT if mi(parttime_POST) & !mi(parttime_POST_TOT)
	drop parttime_POST_TOT
	replace parttime_POST=3 if empl_POST==0 // non-working
	
* final employment variable capturing changes

	* PRE > LOCKDOWN 
	
	ge change_work12=.
	replace change_work12=1 if parttime_PRE==parttime_LOCK & parttime_PRE !=3 & !mi(parttime_PRE, parttime_LOCK)
	replace change_work12=2 if parttime_PRE==parttime_LOCK & parttime_PRE==3 & !mi(parttime_PRE, parttime_LOCK)
	replace change_work12=3 if parttime_PRE<parttime_LOCK & !mi(parttime_PRE, parttime_LOCK)
	replace change_work12=4 if parttime_PRE>parttime_LOCK & !mi(parttime_PRE, parttime_LOCK)
	
	* PRE > POST
	
	ge change_work13=.
	replace change_work13=1 if parttime_PRE==parttime_POST & parttime_PRE !=3 & !mi(parttime_PRE, parttime_POST)
	replace change_work13=2 if parttime_PRE==parttime_POST & parttime_PRE==3 & !mi(parttime_PRE, parttime_POST)
	replace change_work13=3 if parttime_PRE<parttime_POST & !mi(parttime_PRE, parttime_POST)
	replace change_work13=4 if parttime_PRE>parttime_POST & !mi(parttime_PRE, parttime_POST)
	
	la def change_work 1 "No change (working)" 2 "No change (not working)" 		///
					   3 "Lost job/hours" 4 "Gained job/hours"
	la val change_work12 change_work
	la val change_work13 change_work
	
*--------------------------------------------------
* Save cleaned dataset					 						     
*-------------------------------------------------- 
	
save "$data/cope_housework_clean1", replace

*------------------------------------------------------------------------------*
*									  END	   						  		   * 
*------------------------------------------------------------------------------*
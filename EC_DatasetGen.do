clear
clear matrix
clear mata
capture log close
set maxvar 15000
set more off
numlabel, add

* Set local/global macros for current date
local today=c(current_date)
local c_today= "`today'"
global date=subinstr("`c_today'", " ", "",.)

local datadir "/Users/ealarson/Documents/RandomCoding/Emergency_Contraception/Datasets"


cd "$ECfolder"
log using "$ECfolder/log_files/PMA2020_ECMethodology_$date.log", replace

use "`datadir'/Nigeria_National/NG_NatR3.dta"
	pmasample
	keep country state round FQ_age school FQmarital_status last_time_sex last_time_sex_value age_at_first_sex current_user ///
		current_method current_methodnum* EC recent_user recent_method recent_methodnum* ///
		current_or_recent_user current_recent_method current_recent_methodnum  ///
		FQweight* cp mcp wealth*
	replace country="NG_Kaduna" if state==1
	replace country="NG_Lagos" if state==2
	replace country="NG_Taraba" if state==3
	replace country="NG_Kano" if state==4
	replace country="NG_Rivers" if state==5
	replace country="NG_Nasarawa" if state==6
	replace country="NG_Anambra" if state==7	
	drop state
	save "`datadir'/EC/EC_v2.dta", replace

foreach dataset in ///
	"`datadir'/BurkinaFaso/BFR4.dta" ///
	"`datadir'/DRC_BC/DC_BCR5.dta" ///
	"`datadir'/DRC_Kinshasa/DC_KinR5.dta" ///
	"`datadir'/Ethiopia/ETR4.dta" ///
	"`datadir'/Ghana/GHR4.dta" ///
	"`datadir'/Kenya/KER5.dta" ///
	"`datadir'/Niger_National/NE_NatR2.dta" ///
	"`datadir'/Rajasthan/INR1.dta" ///
	"`datadir'/Uganda/UGR4.dta" {
	preserve
		use `dataset'
		pmasample
		if country=="CD" {
			replace country="CD_CK" if province==2
			replace country="CD_Kinshasa" if province==1
			}
		keep country round FQ_age school FQmarital_status last_time_sex last_time_sex_value age_at_first_sex current_user ///
			current_method current_methodnum* EC recent_user recent_method recent_methodnum* ///
			current_or_recent_user current_recent_method current_recent_methodnum  ///
			FQweight* cp mcp wealth* 
		tempfile dataset
		save `dataset', replace
	restore
	append using `dataset', force
	save, replace
	}
	
foreach dataset in ///
	"`datadir'/BurkinaFaso/BFR5.dta" ///
	"`datadir'/Kenya/KER6.dta" {
	preserve
		use `dataset'
		pmasample
		keep country round FQ_age school FQmarital_status last_time_sex last_time_sex_value age_at_first_sex current_user ///
			current_method current_methodnum* EC recent_user recent_method recent_methodnum* ///
			current_or_recent_user current_recent_method current_recent_methodnum  ///
			FQweight* cp mcp wealth* emergency_12mo_yn
		if country=="BF" {
			replace country="BF_R5"
			}
		if country=="KE" {
			replace country="KE_R6"
			}
		tempfile dataset
		save `dataset', replace
	restore
	append using `dataset', force
	save, replace
	}

foreach region in Lagos Kaduna Rivers Taraba Anambra Nasarawa Kano {
	replace FQweight=FQweight_`region' if FQweight_`region'!=.
	drop FQweight_`region'
	replace wealthquintile=wealthquintile_`region' if wealthquintile_`region'!=.
	drop wealthquintile_`region'
	}
	
save "`datadir'/ECdata_v2.dta", replace
		

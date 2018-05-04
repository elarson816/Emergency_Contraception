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

global ECfolder "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/EC_Analysis"
global resultsdir "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/EC_Analysis/Tabout"
local datadir "/Users/ealarson/Documents/RandomCoding/Emergency_Contraception/Datasets"
local country_list "BF BF_R5 CD_Kinshasa CD_CK ET GH India_Rajasthan KE KE_R6 NE NG_Kaduna NG_Lagos NG_Taraba NG_Kano NG_Rivers NG_Nasarawa NG_Anambra UG"
local country_list2 "BF BF_R5 KE KE_R6"
local excel "$resultsdir/ECAnalysis_$date.xls"
local excel_marriage "$resultsdir/ECAnalysis_MaritalStatus_$date.xls"
local excel_sex "$resultsdir/ECAnalysis_SexStatus_$date.xls"

cd "$ECfolder"
log using "$ECfolder/log_files/PMA2020_ECMethodology_$date.log", replace
use "`datadir'/ECdata_v2.dta"

********************************************************************************
*Section A. Data Prep
********************************************************************************

**Generate EC Variables**
gen EC_recent_methodnum=.
replace EC_recent_methodnum=1 if EC==1 | recent_methodnum==8
replace EC_recent_methodnum=. if mcp!=1
label define yes_no 0 "0. No" 1 "1. Yes"
label val EC_recent_methodnum yes_no

gen EC_measure2=.
replace EC_measure2=1 if current_methodnum==8 | recent_methodnum==8

gen EC_measure5=.
replace EC_measure5=1 if EC==1 & (country=="BF_R5" | country=="KE_R6")
replace EC_measure5=1 if emergency_12mo_yn==1 & (country=="BF_R5" | country=="KE_R6")

gen EC_measure5v2=.
replace EC_measure5v2=1 if current_methodnum==8 & (country=="BF_R5" | country=="KE_R6")
replace EC_measure5v2=1 if emergency_12mo_yn==1 & (country=="BF_R5" | country=="KE_R6")

* Generate Mesaure Variables
bysort country: egen measure1=count(current_methodnum) if current_methodnum==8
	label var measure1 "Measure 1 - conventional method mix"
bysort country: egen measure2=count(EC_measure2) if current_recent_methodnum==8 //& mcp==1
	label var measure2 "Measure 2 - PMA method mix"
bysort country: egen measure3=count(EC) if EC==1
	label var measure3 "Measure 3 - current EC use"
bysort country: egen measure4=count(EC_recent_methodnum) if EC_recent_methodnum==1
	label var measure4 "Measure 4 - current EC use all users + 12 month"
bysort country: egen measure5=count(EC_measure5)
	label var measure5 "Measure 5 - current EC use (EC) + 12 month"
bysort country: egen measure5v2=count(EC_measure5v2)
	label var measure5v2 "Measure 5 v2 - current EC use (MM) + 12 month"

* Generate Sex in last 30 days variable
	gen sex_30days=  ///
		( (last_time_sex==1 & last_time_sex_value<=30 & last_time_sex_value>=0) ///
		| (last_time_sex==2 & last_time_sex_value<=4 & last_time_sex_value>=0)  ///
		| (last_time_sex==3 & last_time_sex_value<=1 & last_time_sex_value>=0) )
	gen sex_12months=  ///
		( (last_time_sex==1 & last_time_sex_value<=365 & last_time_sex_value>=0) ///
		| (last_time_sex==2 & last_time_sex_value<=52 & last_time_sex_value>=0)  ///
		| (last_time_sex==3 & last_time_sex_value<=12 & last_time_sex_value>=0) )
		
* Generate marriage variable
gen married=0 
	replace married=1 if FQmarital_status==1 | FQmarital_status==2
	
* Generat unmarried sexually active variable
gen umsexactive=0 
replace umsexactive=1 if married==0 & ( (last_time_sex==1 & last_time_sex_value<=365 & last_time_sex_value>=0) ///
		| (last_time_sex==2 & last_time_sex_value<=52 & last_time_sex_value>=0)  ///
		| (last_time_sex==3 & last_time_sex_value<=12 & last_time_sex_value>=0) )
		
/********************************************************************************
*Section B. Analysis
********************************************************************************
*Initial Tabouts
tabout country round using "`excel'", replace ///
	c(freq) f(0) npos(row) h1("Country/Round")
foreach country in `country_list' {	
	tabout current_methodnum if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 1 for `country', weighted")
	tabout EC_measure2 if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 2 for `country', weighted")
	tabout EC if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 3 for `country', weighted")
	tabout EC_recent_methodnum if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 4 for `country', weighted")
	capture noisily tabout EC_measure5 if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 5 for `country', weighted")
	}

*Tabouts by marital status	
preserve
keep if married==1
tabout country round using "`excel_marriage'", replace ///
	c(freq) f(0) npos(row) h1("Country/Round")
foreach country in `country_list' {	
	tabout current_methodnum if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 1 for `country', married women, weighted")
	tabout EC_measure2 if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 2 for `country', married women, weighted")
	tabout EC if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 3 for `country', married women, weighted")
	tabout EC_recent_methodnum if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 4 for `country', married women, weighted")
	capture noisily tabout EC_measure5 if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 5 for `country', married women, weighted")
	}
restore

*Tabouts for unmarried sexually active women 
preserve
keep if umsexactive==1
tabout country round using "`excel_sex'", replace ///
	c(freq) f(0) npos(row) h1("Country/Round")
foreach country in `country_list' {	
	tabout current_methodnum if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 1 for `country', married women, weighted")
	tabout EC_measure2 if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 2 for `country', married women, weighted")
	tabout EC if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 3 for `country', married women, weighted")
	tabout EC_recent_methodnum if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 4 for `country', married women, weighted")
	capture noisily tabout EC_measure5 if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 5 for `country', married women, weighted")
	}
restore
	

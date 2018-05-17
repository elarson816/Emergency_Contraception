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
local country_list "BF_R5 CD_Kinshasa CD_CK ET GH India_Rajasthan KE_R6 NE NG_Kaduna NG_Lagos NG_Taraba NG_Kano NG_Rivers NG_Nasarawa NG_Anambra UG"
local country_list2 "BF BF_R5 KE KE_R6"
local measure_list "EC_measure1 EC_measure2 EC_measure3 EC_measure4"
local measure_list2 "EC_measure1 EC_measure4 EC_measure5"
local excel "$resultsdir/ECAnalysis_$date.xls"
local excel_marriage "$resultsdir/ECAnalysis_MaritalStatus_$date.xls"
local excel_sex "$resultsdir/ECAnalysis_SexStatus_$date.xls"
local excel_paper "$resultsdir/ECAnalysis_PaperTables_$date.xls"
local excel_paper_2 "$resultsdir/ECAnalysis_PaperTablesv2_$date.xls"


cd "$ECfolder"
log using "$ECfolder/log_files/PMA2020_ECMethodology_$date.log", replace
use "`datadir'/ECdata_v2.dta"

********************************************************************************
*Section A. Data Prep
********************************************************************************
label define yes_no 0 "0. No" 1 "1. Yes"

**Generate EC Variables**
gen EC_measure1=0
replace EC_measure1=1 if current_methodnum==8
label val EC_measure1 yes_no

gen EC_measure2=0
replace EC_measure2=1 if current_methodnum==8 | recent_methodnum==8
label val EC_measure2 yes_no

gen EC_measure3=EC
label val EC_measure3 yes_no

gen EC_measure4=0
replace EC_measure4=1 if EC==1 | recent_methodnum==8
label val EC_measure4 yes_no

gen EC_measure5=0
replace EC_measure5=1 if EC==1 & (country=="BF_R5" | country=="KE_R6")
replace EC_measure5=1 if emergency_12mo_yn==1 & (country=="BF_R5" | country=="KE_R6")
label val EC_measure5 yes_no

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
		
*Age groups
egen age5=cut(FQ_age), at(15(5)50)

/********************************************************************************
*Section B. Analysis
********************************************************************************
*Initial Tabouts
tabout country round using "`excel'", replace ///
	c(freq) f(0) npos(row) h1("Country/Round")
foreach country in `country_list' {	
	tabout EC_measure1 if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 1 for `country', weighted")
	tabout EC_measure2 if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 2 for `country', weighted")
	tabout EC_measure3 if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 3 for `country', weighted")
	tabout EC_measure4 if country=="`country'" [aw=FQweight] using "`excel'", mi append ///
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
	tabout EC_measure1 if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 1 for `country', married women, weighted")
	tabout EC_measure2 if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 2 for `country', married women, weighted")
	tabout EC_measure3 if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 3 for `country', married women, weighted")
	tabout EC_measure4 if country=="`country'" [aw=FQweight] using "`excel_marriage'", mi append ///
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
	tabout EC_measure1 if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 1 for `country', unmarried sexually active women, weighted")
	tabout EC_measure2 if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 2 for `country', unmarried sexually active women, weighted")
	tabout EC_measure3 if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 3 for `country', unmarried sexually active women, weighted")
	tabout EC_measure4 if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 4 for `country', unmarried sexually active women, weighted")
	capture noisily tabout EC_measure5 if country=="`country'" [aw=FQweight] using "`excel_sex'", mi append ///
		c(freq col) f(0 2) npos(row) ///
		h2("Measure 5 for `country', unmarried sexually active women, weighted")
	}
restore
*
********************************************************************************
*Section B. Analysis
********************************************************************************

tabout country using "`excel_paper'", replace ///
	c(freq) f(0) npos(row) h1("Country")

*Table 0 - Background Characteristics
foreach country in `country_list' {
	capture confirm strata
	if _rc!=0 {
		svyset EA [pw=FQweight], singleunit(scaled)
		}
	else { 
		svyset EA [pw=FQweight], strata(strata) singleunit(scaled)
		}
	tabout one if country=="`country'" [aw=FQweight] using "`excel_paper'", mi append ///
		h2("Table 0: Total informants for `country'")
	tabout married umsexactive age5 if country=="`country'" [aw=FQweight] using "`excel_paper'", oneway mi append ///
		c(col ci) f(1 1) clab(Column_% 95%_CI) svy npos(lab) percent ///
		h2("Table 0: Background Characterisitcs for `country'")
		}
*		
*Table 1
foreach country in `country_list' {
	capture confirm strata
	if _rc!=0 {
		svyset EA [pw=FQweight], singleunit(scaled)
		}
	else { 
		svyset EA [pw=FQweight], strata(strata) singleunit(scaled)
		}
	tabout `measure_list' if country=="`country'" ///
		[aw=FQweight] using "`excel_paper'", oneway mi append ///
		c(col ci) f(2 1) clab(Column_% 95%_CI) svy npos(lab) percent show(all) ///
		h2("Table 1: Percent estimate of use for `country'")
	}
	
*Table 2*/
drop if country=="BF" | country=="KE"
preserve
collapse (mean) `measure_list' [pw=FQweight], by(country)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent-EC_measure1_percent
	}
drop `measure_list'
order EC_measure2_percent, after(EC_measure1_percent)
order EC_measure3_percent, after(EC_measure2_percent)
order EC_measure4_percent, after(EC_measure3_percent)
export excel using "`excel_paper_2'", sheet("total_means") firstrow(variables) replace
restore

*Table 3
preserve
collapse (mean) `measure_list' [pw=FQweight], by(country married) 
foreach measure in `measure_list' {
	keep if married==1
	gen `measure'_percent_mar=`measure'*100
	bysort country: gen `measure'_diff_measure1_mar=`measure'_percent-EC_measure1_percent if married==1
	}
drop if married==0
drop `measure_list'
order EC_measure2_percent_mar, after(EC_measure1_percent_mar)
order EC_measure3_percent_mar, after(EC_measure2_percent_mar)
order EC_measure4_percent_mar, after(EC_measure3_percent_mar)
export excel using "`excel_paper_2'", sheet("married_means") first(variable) replace
restore

preserve
collapse (mean) `measure_list' [pw=FQweight], by(country umsexactive)
foreach measure in `measure_list' {
	gen `measure'_percent_umsa=`measure'*100
	bysort country: gen `measure'_diff_measure1_umsa=`measure'_percent-EC_measure1_percent if umsexactive==1
	}
drop if umsexactive==0
drop `measure_list'
order EC_measure2_percent_umsa, after(EC_measure1_percent_umsa)
order EC_measure3_percent_umsa, after(EC_measure2_percent_umsa)
order EC_measure4_percent_umsa, after(EC_measure3_percent_umsa)
export excel using "`excel_paper_2'", sheet("umsa_means") first(variable)
restore

preserve
gen u20=.
replace u20=1 if FQ_age<20
collapse (mean) `measure_list' [pw=FQweight], by(country u20)
foreach measure in `measure_list' {
	gen `measure'_percent_u20=`measure'*100
	bysort country: gen `measure'_diff_measure1_u20=`measure'_percent-EC_measure1_percent if u20==1
	}
drop if u20==.
drop if EC_measure1_percent_u20==0
drop `measure_list'
order EC_measure2_percent_u20, after(EC_measure1_percent_u20)
order EC_measure3_percent_u20, after(EC_measure2_percent_u20)
order EC_measure4_percent_u20, after(EC_measure3_percent_u20)
export excel using "`excel_paper_2'", sheet("u20_means") first(variable) 
restore

preserve
gen u25=.
replace u25=1 if FQ_age<25
collapse (mean) `measure_list' [pw=FQweight], by(country u25)
foreach measure in `measure_list' {
	gen `measure'_percent_u25=`measure'*100
	bysort country: gen `measure'_diff_measure1_u25=`measure'_percent-EC_measure1_percent if u25==1
	}
drop if u25==.
drop if EC_measure1_percent_u25==0
drop `measure_list'
order EC_measure2_percent_u25, after(EC_measure1_percent_u25)
order EC_measure3_percent_u25, after(EC_measure2_percent_u25)
order EC_measure4_percent_u25, after(EC_measure3_percent_u25)
export excel using "`excel_paper_2'", sheet("u25_means") first(variable) 
restore

*Table 4
preserve
keep if country=="BF_R5" | country=="KE_R6"
collapse (mean) `measure_list2' [pw=FQweight], by(country)
foreach measure in `measure_list2' {
	gen `measure'_percent=`measure'*100
	}
bysort country: gen EC_measure5_diff_measure1=EC_measure5_percent-EC_measure1_percent
bysort country: gen EC_measure5_diff_measure4=EC_measure5_percent-EC_measure4_percent
drop `measure_list2'
order EC_measure4_percent, after(EC_measure1_percent)
order EC_measure5_percent, after(EC_measure4_percent)
export excel using "`excel_paper_2'", sheet("Measure5") first(variable) 
restore

*Graph 1
preserve
collapse (mean) `measure_list' [pw=FQweight], by(country)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent-EC_measure1_percent
	}
drop `measure_list'
twoway ///
	(scatter EC_measure2_diff_measure1 EC_measure1_percent) ///
	(scatter EC_measure3_diff_measure1 EC_measure1_percent) ///
	(scatter EC_measure4_diff_measure1 EC_measure1_percent), ///
	xtitle(Measure1 by country)
restore

*Graph 2
preserve
collapse (mean) `measure_list' mcp [pw=FQweight], by(country)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	}
drop `measure_list'
twoway ///
	(scatter EC_measure1_percent mcp) ///
	(scatter EC_measure2_percent mcp) ///
	(scatter EC_measure3_percent mcp) ///
	(scatter EC_measure4_percent mcp), ///
	xtitle(mcp by country)






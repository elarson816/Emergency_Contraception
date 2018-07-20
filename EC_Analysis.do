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
local country_list "BF CD_Kinshasa CD_CK ET GH India_Rajasthan KE NE NG_Kaduna NG_Lagos NG_Taraba NG_Kano NG_Rivers NG_Nasarawa NG_Anambra UG"
local country_list2 "BF KE"
local measure_list "EC_measure1 EC_measure2 EC_measure3 EC_measure4"
local measure_list2 "EC_measure1 EC_measure4 EC_measure5"
local subgroup_list "married umsexactive u20 u25"
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

gen EC_measure3=0
replace EC_measure3=1 if EC==1 //gen byte x=EC==1
label val EC_measure3 yes_no

gen EC_measure4=0
replace EC_measure4=1 if EC==1 | recent_methodnum==8
label val EC_measure4 yes_no

gen EC_measure5=0
replace EC_measure5=1 if EC==1 & (country=="BF" | country=="KE")
replace EC_measure5=1 if emergency_12mo_yn==1 & (country=="BF" | country=="KE")
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

gen u20=1 if age5==15
	replace u20=0 if age5!=15
gen u25=1 if age5==20 | age5==15
	replace u25=0 if age5>20
	
forvalues val = 15(5)50 {
	gen age_`val'=1 if age5==`val'
	replace age_`val'=0 if age5!=`val'
	}

********************************************************************************
*Survey Set Data
********************************************************************************
	
capture confirm strata
	if _rc!=0 {
		svyset EA [pw=FQweight], singleunit(scaled)
		}
	else { 
		if inlist(country, "NG_Anambra", "NG_Kaduna", "NG_Kano", "NG_Lagos", "NG_Nasarawa", "NG_Rivers", "NG_Taraba") {
			svyset EA [pw=FQweight], singleunit(scaled)
			}
		else {
			svyset EA [pw=FQweight], strata(strata) singleunit(scaled)
			}
		}	
/********************************************************************************
*Section B. Background Characteristics
********************************************************************************
preserve

replace married=married*100
replace umsexactive=umsexactive*100
replace age_15=age_15*100
replace age_20=age_20*100
replace age_25=age_25*100
replace age_30=age_30*100
replace age_35=age_35*100
replace age_40=age_40*100
replace age_45=age_45*100

foreach country in `country_list' {
	di "`country'"
	tab married [aw=FQweight] if country=="`country'"
	tab umsexactive [aw=FQweight] if country=="`country'"
	svy: prop married umsexactive if country=="`country'"
	tab age5 [aw=FQweight] if country=="`country'"
	svy: prop age_15 age_20 age_25 age_30 age_35 age_40 age_45 if country=="`country'"
	}
	
restore

********************************************************************************
*Section C. Tables
********************************************************************************


*Table 1
preserve

replace EC_measure1=EC_measure1*100
replace EC_measure2=EC_measure2*100
replace EC_measure3=EC_measure3*100
replace EC_measure4=EC_measure4*100

foreach country in `country_list' {
	di "`country'"
	tab EC_measure1 [aw=FQweight] if country=="`country'"
	tab EC_measure2 [aw=FQweight] if country=="`country'"
	tab EC_measure3 [aw=FQweight] if country=="`country'"
	tab EC_measure4 [aw=FQweight] if country=="`country'"
	svy: prop EC_measure1 EC_measure2 EC_measure3 EC_measure4 if country=="`country'"
	}	
svy: prop EC_measure1 EC_measure2 EC_measure3 EC_measure4

restore
	
*Table 2*
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

*Table 2.5*/
foreach country in `country_list' {	
	preserve
	keep if country=="`country'"

	replace married=married*100
	replace umsexactive=umsexactive*100
	replace age_15=age_15*100
	replace age_20=age_20*100
	replace age_25=age_25*100
	replace age_30=age_30*100
	replace age_35=age_35*100
	replace age_40=age_40*100
	replace age_45=age_45*100

	replace EC_measure1=EC_measure1*100
	replace EC_measure2=EC_measure2*100
	replace EC_measure3=EC_measure3*100
	replace EC_measure4=EC_measure4*100

	foreach subgroup in `subgroup_list' {
		di "`country'"
		di "`subgroup'"
		tab EC_measure1 `subgroup' [aw=FQweight]
		tab EC_measure2 `subgroup' [aw=FQweight]
		tab EC_measure3 `subgroup' [aw=FQweight]
		tab EC_measure4 `subgroup' [aw=FQweight]
		svy: prop EC_measure1 EC_measure2 EC_measure3 EC_measure4
		}
	restore
	}	
	
foreach subgroup in `subgroup_list' {
	preserve
	
	replace married=married*100
	replace umsexactive=umsexactive*100
	replace age_15=age_15*100
	replace age_20=age_20*100
	replace age_25=age_25*100
	replace age_30=age_30*100
	replace age_35=age_35*100
	replace age_40=age_40*100
	replace age_45=age_45*100

	replace EC_measure1=EC_measure1*100
	replace EC_measure2=EC_measure2*100
	replace EC_measure3=EC_measure3*100
	replace EC_measure4=EC_measure4*100
	
	di "`subgroup'"
	svy: prop EC_measure1 EC_measure2 EC_measure3 EC_measure4 if `subgroup'==1
	
	restore
	}

assert 0
*Table 3*
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
collapse (mean) `measure_list' [pw=FQweight], by(country u20)
foreach measure in `measure_list' {
	gen `measure'_percent_u20=`measure'*100
	bysort country: gen `measure'_diff_measure1_u20=`measure'_percent-EC_measure1_percent if u20==1
	}
drop if u20==0
drop `measure_list'
order EC_measure2_percent_u20, after(EC_measure1_percent_u20)
order EC_measure3_percent_u20, after(EC_measure2_percent_u20)
order EC_measure4_percent_u20, after(EC_measure3_percent_u20)
export excel using "`excel_paper_2'", sheet("u20_means") first(variable) 

restore

preserve
collapse (mean) `measure_list' [pw=FQweight], by(country u25)
foreach measure in `measure_list' {
	gen `measure'_percent_u25=`measure'*100
	bysort country: gen `measure'_diff_measure1_u25=`measure'_percent-EC_measure1_percent if u25==1
	}
drop if u25==0
drop `measure_list'
order EC_measure2_percent_u25, after(EC_measure1_percent_u25)
order EC_measure3_percent_u25, after(EC_measure2_percent_u25)
order EC_measure4_percent_u25, after(EC_measure3_percent_u25)
export excel using "`excel_paper_2'", sheet("u25_means") first(variable) 
restore


*Table 4*
preserve

keep if country=="BF" | country=="KE"
foreach country in BF KE {
	di "`country'"
	
	tab EC_measure5 [aw=FQweight] if country=="`country'"
	svy: prop EC_measure5  if country=="`country'"
	}
	
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

********************************************************************************
*Section D. Graphs
********************************************************************************

*Graph 1*
preserve
drop if country=="KE"
drop if country=="BF"

replace country="Burkina Faso" if country=="BF_R5"
replace country="DRC Kinshasa" if country=="CD_Kinshasa"
replace country="DRC Kongo Central" if country=="CD_CK"
replace country="Ethiopia" if country=="ET"
replace country="Ghana" if country=="GH"
replace country="India Rajasthan" if country=="India_Rajasthan"
replace country="Kenya" if country=="KE_R6"
replace country="Niger" if country=="NE"
replace country="Nigeria Anambra" if country=="NG_Anambra"
replace country="Nigeria Kaduna" if country=="NG_Kadune"
replace country="Nigeria Kano" if country=="NG_Kano"
replace country="Nigeria Lagos" if country=="NG_Lagos"
replace country="Nigeria Nasarawa" if country=="NG_Nasarawa"
replace country="Nigeria Rivers" if country=="NG_Rivers"
replace country="Nigera Taraba" if country=="NG_Taraba"
replace country="Uganda" if country=="UG"

collapse (mean) `measure_list' [pw=FQweight], by(country)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent-EC_measure1_percent
	}
drop `measure_list'
twoway ///
	scatter EC_measure2_diff_measure1 EC_measure3_diff_measure1 EC_measure4_diff_measure1 EC_measure1_percent, ///
	ylabel(0(.2)1) ymtick(0(.1)1) ytitle("Percentage point difference with measure 1") ysize(7) /// 
	xlabel(0(.2)2) xmtick(0(.1)2) xtitle("Measure 1 by country") xsize(10) ///
	msize(vsmall vsmall vsmall) mlabel(country country country) mlabsize(vsmall vsmall vsmall) msymbol(square circle triangle) ///
	legend(rows(1)) legend(size(2))
graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/EC_Analysis/Tabout/EC_Graph1", as(pdf) replace
restore

*Graph 2*
preserve
drop if country=="KE"
drop if country=="BF"

replace country="Burkina Faso" if country=="BF_R5"
replace country="DRC Kinshasa" if country=="CD_Kinshasa"
replace country="DRC Kongo Central" if country=="CD_CK"
replace country="Ethiopia" if country=="ET"
replace country="Ghana" if country=="GH"
replace country="India Rajasthan" if country=="India_Rajasthan"
replace country="Kenya" if country=="KE_R6"
replace country="Niger" if country=="NE"
replace country="Nigeria Anambra" if country=="NG_Anambra"
replace country="Nigeria Kaduna" if country=="NG_Kadune"
replace country="Nigeria Kano" if country=="NG_Kano"
replace country="Nigeria Lagos" if country=="NG_Lagos"
replace country="Nigeria Nasarawa" if country=="NG_Nasarawa"
replace country="Nigeria Rivers" if country=="NG_Rivers"
replace country="Nigera Taraba" if country=="NG_Taraba"
replace country="Uganda" if country=="UG"

collapse (mean) `measure_list' mcp [pw=FQweight], by(country)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	}
drop `measure_list'
twoway ///
	scatter EC_measure1_percent EC_measure2_percent EC_measure3_percent EC_measure4_percent mcp, ///
	ylabel(0(.4)2.4) ymtick(0(.2)2.4) ytitle("Measures 1, 2, 3 and 4 (%)") ///
	xlabel(0(.2).6) xmtick(0(.1).6) xtitle("MCP by country") ///
	msize(vsmall vsmall vsmall vsmall) mlabel(country country country country) mlabsize(vsmall vsmall vsmall vsmall) msymbol(square circle triangle diamond) ///
	legend(rows(1)) legend(size(2))
graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/EC_Analysis/Tabout/EC_Graph2", as(pdf) replace
restore





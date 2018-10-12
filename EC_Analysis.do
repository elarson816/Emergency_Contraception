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

local country_list "BF CdI CD_Kinshasa CD_CK ET GH India_Rajasthan KE NE NG_Anambra NG_Kaduna NG_Kano NG_Lagos NG_Nasarawa NG_Taraba NG_Rivers UG"
local country_list2 "BF KE UG"

local measure_list "EC_measure1 EC_measure2 EC_measure3 EC_measure4"
local measure_list2 "EC_measure1 EC_measure4 EC_measure5"

local subgroup_list "married umsexactive u20 u25"

local tabout_excel "$resultsdir/ECAnalysis_Tabouts_v2_$date.xls"
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
		
********************************************************************************
*Section B. Background Characteristics
********************************************************************************
/*

tabout country using "`tabout_excel'"

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
	tabout married [aw=FQweight] if country=="`country'" using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Married women: `country'") append
	tabout umsexactive [aw=FQweight] if country=="`country'" using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Unmarried sexually active women: `country'") append
	svy: prop married umsexactive if country=="`country'"
	tabout age5 [aw=FQweight] if country=="`country'" using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Age: `country'") append
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
	tabout EC_measure1 [aw=FQweight] if country=="`country'" using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 1: `country'") append
	tabout EC_measure2 [aw=FQweight] if country=="`country'" using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 2: `country'") append
	tabout EC_measure3 [aw=FQweight] if country=="`country'" using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 3: `country'") append
	tabout EC_measure4 [aw=FQweight] if country=="`country'" using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 4: `country'") append
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

*Table 2.5*
foreach country in `country_list' {	
	preserve
	keep if country=="`country'"

	foreach subgroup in `subgroup_list' {
		di "`country'"
		di "`subgroup'"
		tabout EC_measure1 `subgroup' [aw=FQweight] using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 1: `country' `subgroup'") append
		tabout EC_measure2 `subgroup' [aw=FQweight] using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 2: `country' `subgroup'") append
		tabout EC_measure3 `subgroup' [aw=FQweight] using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 3: `country' `subgroup'") append
		tabout EC_measure4 `subgroup' [aw=FQweight] using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 4: `country' `subgroup'") append
		svy: prop EC_measure1 EC_measure2 EC_measure3 EC_measure4 if `subgroup'==1
		}
	restore
	}	
	
foreach subgroup in `subgroup_list' {
	di "`subgroup'"
	svy: prop EC_measure1 EC_measure2 EC_measure3 EC_measure4 if `subgroup'==1
	}


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
export excel using "`excel_paper_2'", sheet("married_means") first(variable)
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

foreach country in `country_list2' {
	di "`country'"
	
	tab EC_measure5 [aw=FQweight] if country=="`country'"
	svy: prop EC_measure5  if country=="`country'"
	
	foreach subgroup in `subgroup_list' {
		di "`subgroup'"
		tabout EC_measure5 `subgroup' [aw=FQweight] using "`tabout_excel'", cells(freq col) f(0 2) ///
		h2("Measure 5: `country' `subgroup'") append
		svy: prop EC_measure5 if `subgroup'==1
		}
	}
	

preserve
keep if country=="BF" | country=="KE" | country=="UG"

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

preserve
keep if country=="BF" | country=="KE" | country=="UG"

collapse (mean) `measure_list2' [pw=FQweight], by(country married)
foreach measure in `measure_list2' {
	keep if married==1
	gen `measure'_percent_mar=`measure'*100
	bysort country: gen `measure'_diff_measure1_mar=`measure'_percent-EC_measure1_percent if married==1
	}
drop if married==0
drop `measure_list2'
order EC_measure4_percent_mar, after(EC_measure1_percent_mar)
order EC_measure5_percent_mar, after(EC_measure4_percent_mar)
export excel using "`excel_paper_2'", sheet("Measure5_married_means") first(variable)
restore

preserve
keep if country=="BF" | country=="KE" | country=="UG"

collapse (mean) `measure_list2' [pw=FQweight], by(country umsexactive)
foreach measure in `measure_list2' {
	keep if umsexactive==1
	gen `measure'_percent_umsa=`measure'*100
	bysort country: gen `measure'_diff_measure1_umsa=`measure'_percent-EC_measure1_percent if umsexactive==1
	}
drop if umsexactive==0
drop `measure_list2'
order EC_measure4_percent_umsa, after(EC_measure1_percent_umsa)
order EC_measure5_percent_umsa, after(EC_measure4_percent_umsa)
export excel using "`excel_paper_2'", sheet("Measure5_umsa_means") first(variable)
restore

preserve
keep if country=="BF" | country=="KE" | country=="UG"

collapse (mean) `measure_list2' [pw=FQweight], by(country u20)
foreach measure in `measure_list2' {
	keep if u20==1
	gen `measure'_percent_u20=`measure'*100
	bysort country: gen `measure'_diff_measure1_u20=`measure'_percent-EC_measure1_percent if u20==1
	}
drop if u20==0
drop `measure_list2'
order EC_measure4_percent_u20, after(EC_measure1_percent_u20)
order EC_measure5_percent_u20, after(EC_measure4_percent_u20)
export excel using "`excel_paper_2'", sheet("Measure5_u20_means") first(variable)
restore

preserve
keep if country=="BF" | country=="KE" | country=="UG"

collapse (mean) `measure_list2' [pw=FQweight], by(country u25)
foreach measure in `measure_list2' {
	keep if u25==1
	gen `measure'_percent_u25=`measure'*100
	bysort country: gen `measure'_diff_measure1_u25=`measure'_percent-EC_measure1_percent if u25==1
	}
drop if u25==0
drop `measure_list2'
order EC_measure4_percent_u25, after(EC_measure1_percent_u25)
order EC_measure5_percent_u25, after(EC_measure4_percent_u25)
export excel using "`excel_paper_2'", sheet("Measure5_u25_means") first(variable)
restore
*/

********************************************************************************
*Section D. Graphs
********************************************************************************
/*
replace country="Burkina Faso" if country=="BF"
replace country="DRC Kinshasa" if country=="CD_Kinshasa"
replace country="DRC Kongo Central" if country=="CD_CK"
replace country="Cote d'Ivoire" if country=="CdI"
replace country="Ethiopia" if country=="ET"
replace country="Ghana" if country=="GH"
replace country="India Rajasthan" if country=="India_Rajasthan"
replace country="Kenya" if country=="KE"
replace country="Niger" if country=="NE"
replace country="Nigeria Anambra" if country=="NG_Anambra"
replace country="Nigeria Kaduna" if country=="NG_Kaduna"
replace country="Nigeria Kano" if country=="NG_Kano"
replace country="Nigeria Lagos" if country=="NG_Lagos"
replace country="Nigeria Nasarawa" if country=="NG_Nasarawa"
replace country="Nigeria Rivers" if country=="NG_Rivers"
replace country="Nigeria Taraba" if country=="NG_Taraba"
replace country="Uganda" if country=="UG"

*Graph 1*
preserve

collapse (mean) `measure_list' [pw=FQweight], by(country)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent-EC_measure1_percent
	}
drop `measure_list'
twoway ///
	lfitci EC_measure2_diff_measure1 EC_measure1_percent, lcolor(blue) acolor(ltblue%10) || ///
	scatter EC_measure2_diff_measure1 EC_measure1_percent, /// 
		mcolor(blue) msize(vsmall) mlabel(country) mlabsize(vsmall) mlabcolor(blue) msymbol(square) || ///
	lfitci EC_measure3_diff_measure1 EC_measure1_percent, lcolor(purple) acolor(lavender%5) || ///
	scatter EC_measure3_diff_measure1 EC_measure1_percent, ///
		mcolor(purple) msize(vsmall) mlabel(country) mlabsize(vsmall) mlabcolor(purple) msymbol(circle) || ///
	lfitci EC_measure4_diff_measure1 EC_measure1_percent, lcolor(gs7) acolor(gs7%5) || ///
	scatter EC_measure4_diff_measure1 EC_measure1_percent, ///
		mcolor(gs7) msize(vsmall) mlabel(country) mlabsize(vsmall) mlabcolor(gs7) msymbol(triangle) ///
	ylabel(0(.2)1) ymtick(0(.1)1) ytitle("Percentage Point") ysize(7) /// 
	xlabel(0(.4)2.8) xmtick(0(.1)2.8) xtitle("Measure 1 By Country") xsize(10) ///
	legend(label(1 "Measure 2, 95% CI") label(4 "Measure 3, 95% CI") label (7 "Measure 4, 95% CI")) ///
	legend(label(2 "Measure 2 Fitted Value") label(5 "Measure 3 Fitted Value") label(8 "Measure 4 Fitted Value")) ///
	legend(label(3 "Measure 2") label(6 "Measure 3") label(9 "Measure 4")) ///
	legend(rows(3) size(small)) ///
	title("Percentage point difference with Measure 1 by Country") subtitle("Measures 2, 3 and 4; Fitted lines; and 95% CI")
	
graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/EC_Analysis/Tabout/EC_Graph1", as(pdf) replace
restore


*Graph 2*
preserve

collapse (mean) `measure_list' mcp [pw=FQweight], by(country)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	}
drop `measure_list'
twoway ///
	lfitci EC_measure1_percent mcp, lcolor(red) acolor(pink%5) || ///
	scatter EC_measure1_percent mcp, ///
		mcolor(red) msize(vsmall) mlabel(country) mlabsize(vsmall) mlabcolor(red) msymbol(diamond) || ///
	lfitci EC_measure2_percent mcp, lcolor(blue) acolor(ltblue%10) || ///
	scatter EC_measure2_percent mcp, ///
		mcolor(blue) msize(vsmall) mlabel(country) mlabsize(vsmall) mlabcolor(blue) msymbol(square) || ///
	lfitci EC_measure3_percent mcp, lcolor(purple) acolor(lavender%5) || ///
	scatter EC_measure3_percent mcp, ///
		mcolor(purple) msize(vsmall) mlabel(country) mlabsize(vsmall) mlabcolor(purple) msymbol(circle) || ///
	lfitci EC_measure4_percent mcp, lcolor(gs7) acolor(gs7%5) || ///
	scatter EC_measure4_percent mcp, ///	
		mcolor(gs7) msize(vsmall) mlabel(country) mlabsize(vsmall) mlabcolor(gs7) msymbol(triangle) ///
	ylabel(0(.4)2.4) ymtick(0(.2)2.4) ytitle("Percent") ///
	xlabel(0(.2).6) xmtick(0(.1).6) xtitle("MCP by country") ///
	legend(label(1 "Measure 1, 95% CI") label(4 "Measure 2, 95% CI") label(7 "Measure 3, 95% CI") label(10 "Measure 4, 95% CI")) ///
	legend(label(2 "Measure 1 Fitted Value") label(5 "Measure 2 Fitted Value") label(8 "Measure 3 Fitted Value") label(11 "Measure 4 Fitted Value")) ///
	legend(label(3 "Measure 1") label(6 "Measure 2") label(9 "Measure 3") label(12 "Measure 4")) ///
	legend(rows(4) size(vsmall)) ///
	title("Emergency Contraception use and" "Modern Contraceptive Prevalence Rate by Country") subtitle("Measures 1, 2, 3 and 4; Fitted lines, and 95% CI")
graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/EC_Analysis/Tabout/EC_Graph2", as(pdf) replace
restore

*/
********************************************************************************
*Section E. New Graphs
********************************************************************************
*Graph Prep
foreach measure in `measure_list' {
	gen se_`measure'=.
	gen lb_`measure'=.
	gen ub_`measure'=.
	}

foreach country in `country_list' {
	foreach measure in `measure_list' {
		svy: prop `measure' if country=="`country'"
		matrix one=r(table)
		matrix `measure'_lb_`country'=one[5,2]
		matrix `measure'_ub_`country'=one[6,2]
		matrix `measure'_se_`country'=one[2,2]
		replace lb_`measure'=`measure'_lb_`country'[1,1] if country=="`country'"
		replace ub_`measure'=`measure'_ub_`country'[1,1] if country=="`country'"
		replace se_`measure'=`measure'_se_`country'[1,1] if country=="`country'"
		}
	}
	

replace country="Burkina Faso" if country=="BF"
replace country="DRC Kinshasa" if country=="CD_Kinshasa"
replace country="DRC Kongo Central" if country=="CD_CK"
replace country="Cote d'Ivoire" if country=="CdI"
replace country="Ethiopia" if country=="ET"
replace country="Ghana" if country=="GH"
replace country="India Rajasthan" if country=="India_Rajasthan"
replace country="Kenya" if country=="KE"
replace country="Niger" if country=="NE"
replace country="Nigeria Anambra" if country=="NG_Anambra"
replace country="Nigeria Kaduna" if country=="NG_Kaduna"
replace country="Nigeria Kano" if country=="NG_Kano"
replace country="Nigeria Lagos" if country=="NG_Lagos"
replace country="Nigeria Nasarawa" if country=="NG_Nasarawa"
replace country="Nigeria Rivers" if country=="NG_Rivers"
replace country="Nigeria Taraba" if country=="NG_Taraba"
replace country="Uganda" if country=="UG"

label define country_label 1 "Burkina Faso" 2 "Cote d'Ivoire" 3 "DRC Kinshasa" 4 "DRC Kongo Central" 5 "Ethiopia" ///
	6 "Ghana" 7 "India Rajasthan" 8 "Kenya" 9 "Niger" 10 "Nigeria Anambra" 11 "Nigeria Kaduna" ///
	12 "Nigeria Kano" 13 "Nigeria Lagos" 14 "Nigeria Nasarawa" 15 "Nigeria Rivers" 16 "Nigeria Taraba" ///
	17 "Uganda"
encode country, gen(country_v2) label(country_label)


*Graph 1
collapse (mean) `measure_list' [pw=FQweight], by(country_v2 se* lb* ub*)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	gen se_`measure'_percent=se_`measure'*100
	gen lb_`measure'_percent=lb_`measure'*100
	gen ub_`measure'_percent=ub_`measure'*100
	}
	
twoway ///
	scatter EC_measure1_percent country_v2, ///
		mcolor(navy) || ///
	rcap lb_EC_measure1_percent ub_EC_measure1_percent country_v2, ///
		ylabel(0(0.5)4) ytitle("Percent") ///
		xlabel(1 "Burkina Faso" 2 "Cote d'Ivoire" 3 "DRC Kinshasa" 4 "DRC Kongo Central" 5 "Ethiopia" ///
			6 "Ghana" 7 "India Rajasthan" 8 "Kenya" 9 "Niger" 10 "Nigeria Anambra" 11 "Nigeria Kaduna" ///
			12 "Nigeria Kano" 13 "Nigeria Lagos" 14 "Nigeria Nasarawa" 15 "Nigeria Rivers" 16 "Nigeria Taraba" ///
			17 "Uganda", angle(45) labsize(small)) ///
		lcolor(navy) ///
	legend(off) ///
	title("Measure 1 by country") subtitle("Percent Estimate and 95% Confidence Interval")
	/*
twoway ///
	scatter EC_measure1_percent country_v2 if country_v2==8, ///
		mcolor(purple) || ///
	scatter EC_measure1_percent country_v2 if country_v2==8, ///
		mcolor(purple) || ///
	scatter EC_measure1_percent country_v2 if country_v2==8, ///
		mcolor(purple) || ///
	scatter EC_measure1_percent country_v2 if country_v2==8, ///
		mcolor(purple) || ///
	rcap lb_percent ub_percent country_v2 if country_v2==8, ///
		ylabel(0(0.5)4) ytitle("Percent") ///
		xlabel(1 "Measure 1" 2 "Measure 2" 3 "Measure 3" 4 "Measure 4") ///
		lcolor(purple) ///
	legend(off) ///
	title("Kenya: Measures 1 - 4") subtitle("Percent Estimate and 95% Confidence Interval")


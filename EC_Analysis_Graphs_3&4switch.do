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
local measure_list3 "EC_measure1 EC_measure2 EC_measure3 EC_measure4 EC_measure5"

local subgroup_list "married umsexactive u20 u25"

local tabout_excel "$resultsdir/ECAnalysis_Tabouts_v2_$date.xls"
local excel_paper_2 "$resultsdir/ECAnalysis_PaperTablesv2_$date.xls"

cd "$ECfolder"
log using "$ECfolder/log_files/PMA2020_ECMethodology_$date.log", replace
/*
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
replace EC_measure2=1 if EC==1 
label val EC_measure2 yes_no

gen EC_measure3=0
replace EC_measure3=1 if current_methodnum==8 | recent_methodnum==8
label val EC_measure3 yes_no

gen EC_measure4=0
replace EC_measure4=1 if EC==1 | recent_methodnum==8
label val EC_measure4 yes_no

gen EC_measure5=0
replace EC_measure5=1 if EC==1 & (country=="BF" | country=="KE" | country=="UG")
replace EC_measure5=1 if emergency_12mo_yn==1 & (country=="BF" | country=="KE" | country=="UG")
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
*Section 1. Graphs
********************************************************************************
*Graph Prep
foreach measure in `measure_list3' {
	gen se_`measure'=.
	gen lb_`measure'=.
	gen ub_`measure'=.
	
	foreach subgroup in `subgroup_list' {
		gen lb_`subgroup'_`measure'=.
		gen ub_`subgroup'_`measure'=.
		gen se_`subgroup'_`measure'=.
		}
	}

foreach country in `country_list' {
	foreach measure in `measure_list3' {
		svy: prop `measure' if country=="`country'", citype(wilson)
		matrix one=r(table)
		matrix `measure'_lb_`country'=one[5,2]
		matrix `measure'_ub_`country'=one[6,2]
		matrix `measure'_se_`country'=one[2,2]
		replace lb_`measure'=`measure'_lb_`country'[1,1] if country=="`country'"
		replace ub_`measure'=`measure'_ub_`country'[1,1] if country=="`country'"
		replace se_`measure'=`measure'_se_`country'[1,1] if country=="`country'"
		}
	}	
	
foreach country in `country_list' {
	foreach measure in `measure_list3' {
		foreach subgroup in `subgroup_list' {
			svy: prop `measure' if country=="`country'" & `subgroup'==1, citype(wilson)
			matrix one=r(table)
			matrix `measure'_lb_1_`subgroup'=one[5,2]
			matrix `measure'_ub_2_`subgroup'=one[6,2]
			matrix `measure'_se_3_`subgroup'=one[2,2]
			replace lb_`subgroup'_`measure'=`measure'_lb_1_`subgroup'[1,1] if country=="`country'"
			replace ub_`subgroup'_`measure'=`measure'_ub_2_`subgroup'[1,1] if country=="`country'"
			replace se_`subgroup'_`measure'=`measure'_se_3_`subgroup'[1,1] if country=="`country'"
			}
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

save "data_with_ci.dta", replace

*/
use "data_with_ci.dta"

*Graph 1

tempfile graph1_2
collapse (mean) `measure_list' ///
				se* lb* ub*  ///
				[pw=FQweight], by(country_v2)			
				
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	gen se_`measure'_percent=se_`measure'*100
	gen lb_`measure'_percent=lb_`measure'*100
	gen ub_`measure'_percent=ub_`measure'*100
	}

save `graph1_2', replace
use `graph1_2', clear	

format EC_measure1_percent %2.1f
format EC_measure2_percent %2.1f
format EC_measure3_percent %2.1f
format EC_measure4_percent %2.1f
/*
twoway ///
	scatter EC_measure1_percent EC_measure2_percent EC_measure3_percent EC_measure3_percent country_v2, ///
		mcolor("0 0 139") ///
		xtitle("Country/Geography", color(black)) xscale(lwidth(medthick) lcolor("0 0 139")) ///
		xlabel(1 "Burkina Faso" 2 "Cote d'Ivoire" 3 "DRC Kinshasa" 4 "DRC Kongo Central" 5 "Ethiopia" ///
			6 "Ghana" 7 "India Rajasthan" 8 "Kenya" 9 "Niger" 10 "Nigeria Anambra" 11 "Nigeria Kaduna" ///
			12 "Nigeria Kano" 13 "Nigeria Lagos" 14 "Nigeria Nasarawa" 15 "Nigeria Rivers" 16 "Nigeria Taraba" ///
			17 "Uganda", angle(45) labsize(small) labcolor(black) tlcolor("0 0 139")) ///
		lcolor("104 34 139")
assert 0
*/

tempfile high_low
save high_low, replace
keep if inlist(country_v2, 8, 9, 12, 13, 15, 16)
	gen country_v3=1 if country_v2==12
		replace country_v3=2 if country_v2==16
		replace country_v3=3 if country_v2==9
		replace country_v3=4 if country_v2==8
		replace country_v3=5 if country_v2==13
		replace country_v3=6 if country_v2==15
	label define country_v3 1 "Nigeria Kano" 2 "Nigeria Taraba" 3 "Niger" 4 "Kenya" 5 "Nigeria Lagos" 6 "Nigeria Rivers"
	label val country_v3 country_v3
	sort country_v3
	
foreach country in 1 2 3 4 5 6 {
	preserve
	keep if country_v3==`country'
	
	expand 4 in 1
		
	gen measures=1
		replace measures=2 in 2
		replace measures=3 in 3
		replace measures=4 in 4
	gen EC_measure=.
		replace EC_measure=EC_measure1_percent if measures==1
		replace EC_measure=EC_measure2_percent if measures==2
		replace EC_measure=EC_measure3_percent if measures==3
		replace EC_measure=EC_measure4_percent if measures==4
	gen EC_measure_ub=.
		replace EC_measure_ub=ub_EC_measure1_percent if measures==1
		replace EC_measure_ub=ub_EC_measure2_percent if measures==2
		replace EC_measure_ub=ub_EC_measure3_percent if measures==3
		replace EC_measure_ub=ub_EC_measure4_percent if measures==4	
	gen EC_measure_lb=.
		replace EC_measure_lb=lb_EC_measure1_percent if measures==1
		replace EC_measure_lb=lb_EC_measure2_percent if measures==2
		replace EC_measure_lb=lb_EC_measure3_percent if measures==3
		replace EC_measure_lb=lb_EC_measure4_percent if measures==4	

	format EC_measure %2.1f	
	
	tempfile country_`country'
	save country_`country', replace
	restore
	}
	
	use country_1.dta, clear
		append using country_2.dta
		append using country_3.dta
		append using country_4.dta
		append using country_5.dta
		append using country_6.dta
		
	keep country_v3 measures EC_measure EC_measure_ub EC_measure_lb

twoway ///
	(rcap EC_measure_ub EC_measure_lb measures, ///
		lcolor("104 34 139") lwidth(medthick) ///
		ylabel(0(1)4, labcolor(black) tlcolor("0 0 139") glcolor("104 34 139" %15)) ///
		ytick(0(.5)4) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139"))) || ///
	(scatter EC_measure measures, ///
		mcolor("0 0 139") ///
		ylabel(, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
		xlabel(0.5(1)4.5, noticks angle(45)) ///
		xlabel(0.5 " " 1 "Definition 1" 2 "Definition 2" 3 "Definition 3" 4 "Definition 4" 4.5 " ") xtitle("") xscale(lwidth(medthick) lcolor("0 0 139")) ///
		legend(off) graphregion(color(white)) plotregion(color(white))), ///
	by(country_v3, note("") noixtick legend(off) graphregion(color(white)) plotregion(color(white))) play(RemoveBoxColor.grec)
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph1.5_combined", replace
	graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph15_combined.pdf", replace
	   
*Graph 2

foreach country in 1 8 17 {
	preserve
	keep if country_v2==`country'
	expand 4 in 1
	
	local country: label country_label `country'
	
	gen measures=1
		replace measures=2 in 2
		replace measures=3 in 3
		replace measures=4 in 4
	gen EC_measure=.
		replace EC_measure=EC_measure1_percent if measures==1
		replace EC_measure=EC_measure2_percent if measures==2
		replace EC_measure=EC_measure3_percent if measures==3
		replace EC_measure=EC_measure4_percent if measures==4
	gen EC_measure_ub=.
		replace EC_measure_ub=ub_EC_measure1_percent if measures==1
		replace EC_measure_ub=ub_EC_measure2_percent if measures==2
		replace EC_measure_ub=ub_EC_measure3_percent if measures==3
		replace EC_measure_ub=ub_EC_measure4_percent if measures==4	
	gen EC_measure_lb=.
		replace EC_measure_lb=lb_EC_measure1_percent if measures==1
		replace EC_measure_lb=lb_EC_measure2_percent if measures==2
		replace EC_measure_lb=lb_EC_measure3_percent if measures==3
		replace EC_measure_lb=lb_EC_measure4_percent if measures==4	

	format EC_measure %2.1f	
		
	if country_v2==1 {	
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ylabel(0(.5)2.5, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)4.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "Definition 1" 2 "Definition 2" 3 "Definition 3" 4 "Definition 4" 4.5 " ") xtitle("Burkina Faso") xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
	
	if country_v2==8 {
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ylabel(0(.5)2.5, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)4.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "Definition 1" 2 "Definition 2" 3 "Definition 3" 4 "Definition 4" 4.5 " ") xtitle("Kenya") xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
		
	if country_v2==17 {
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ylabel(0(.5)2.5, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)4.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "Definition 1" 2 "Definition 2" 3 "Definition 3" 4 "Definition 4" 4.5 " ") xtitle("Uganda") xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}


	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph2_`country'.gph", replace
	
	
	restore
	}

graph combine "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph2_Burkina Faso" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph2_Kenya" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph2_Uganda", ///
	rows(1) xsize(10) graphregion(color(white)) plotregion(color(white))
	*ycommon title("Definitions 1-4 for Burkina Faso, Kenya, and Uganda") subtitle("Percent Estimate and 95% Confidence Interval")
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph2_combined", replace
	graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph2_combined.pdf", replace


*Graph 3
	
use "data_with_ci.dta", clear

collapse (mean) `measure_list3' [pw=FQweight], by(country_v2)
foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent-EC_measure1_percent
	}
gen EC_measure5_percent=EC_measure5*100
gen EC_measure5_diff_measure1=EC_measure5_percent-EC_measure1_percent if inlist(country_v2, 1, 8, 17)
gen five=5
	
graph ///
	box EC_measure2_diff_measure1 EC_measure3_diff_measure1 EC_measure4_diff_measure1, ///
	box(1, color("104 34 139")) box(2, color("24 116 205")) box(3, color("171 130 255"*1.5)) ///
	box(4, fcolor(none)) ///
	marker(1, mcolor("0 0 139")) marker(2, mcolor("0 0 139")) marker(3, mcolor("0 0 139")) marker(4, mcolor("0 0 139")) ///
	ytitle("Percentage Point", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ///
	ylabel(, labcolor(black) tlcolor("0 0 139") glcolor("104 34 139" %15)) ///
	yvaroptions(axis(lcolor("0 0 139") lwidth(medthick))) ///
	legend(label(1 "1 and 2") label(2 "1 and 3") label(3 "1 and 4") label(4 "1 and 5") rows(1) region(lcolor("0 0 139") lwidth(medium))) ///
	graphregion(color(white)) plotregion(color(white))
	*title("Percentage Point Increase from Definition 1") subtitle("Aggregation over 17 Countries/Geographies")

	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph3", replace
	graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph3.pdf", replace


*Graph 3.5

use "data_with_ci.dta", clear

foreach subgroup in `subgroup_list' {
	preserve	

	collapse (mean) `measure_list3' if `subgroup'==1 [pw=FQweight], by(country_v2)
	foreach measure in `measure_list' {
		gen `measure'_`subgroup'_percent=`measure'*100
		bysort country: gen `measure'_`subgroup'_diff_m1=`measure'_`subgroup'_percent-EC_measure1_`subgroup'_percent
		}
		
	tempfile `subgroup'
	save `subgroup', replace
	restore
	}
	
use married
	append using umsexactive
	append using u20
	append using u25
		
graph ///
	box EC_measure2_married_diff_m1 EC_measure3_married_diff_m1 EC_measure4_married_diff_m1, ///
	box(1, color("104 34 139")) box(2, color("24 116 205")) box(3, color("171 130 255"*1.5)) ///
	box(4, fcolor(none)) ///
	marker(1, mcolor("0 0 139")) marker(2, mcolor("0 0 139")) marker(3, mcolor("0 0 139")) marker(4, mcolor("0 0 139")) ///
	ytitle("Percentage Point", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ///
	ylabel(, labcolor(black) tlcolor("0 0 139") glcolor("104 34 139" %15)) ///
	yvaroptions(axis(lcolor("0 0 139") lwidth(medthick))) ///
	legend(label(1 "1 and 2") label(2 "1 and 3") label(3 "1 and 4") label(4 "1 and 5") rows(1) region(lcolor("0 0 139") lwidth(medium))) ///
	graphregion(color(white)) plotregion(color(white)) ///
	title("Married")
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_married.gph", replace
	
graph ///
	box EC_measure2_umsexactive_diff_m1 EC_measure3_umsexactive_diff_m1 EC_measure4_umsexactive_diff_m1, ///
	box(1, color("104 34 139")) box(2, color("24 116 205")) box(3, color("171 130 255"*1.5)) ///
	box(4, fcolor(none)) ///
	marker(1, mcolor("0 0 139")) marker(2, mcolor("0 0 139")) marker(3, mcolor("0 0 139")) marker(4, mcolor("0 0 139")) ///
	ytitle("Percentage Point", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ///
	ylabel(, labcolor(black) tlcolor("0 0 139") glcolor("104 34 139" %15)) ///
	yvaroptions(axis(lcolor("0 0 139") lwidth(medthick))) ///
	legend(label(1 "1 and 2") label(2 "1 and 3") label(3 "1 and 4") label(4 "1 and 5") rows(1) region(lcolor("0 0 139") lwidth(medium))) ///
	graphregion(color(white)) plotregion(color(white)) ///
	title("Umarried Sexually Active")
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_umsa.gph", replace

graph ///
	box EC_measure2_u20_diff_m1 EC_measure3_u20_diff_m1 EC_measure4_u20_diff_m1, ///
	box(1, color("104 34 139")) box(2, color("24 116 205")) box(3, color("171 130 255"*1.5)) ///
	box(4, fcolor(none)) ///
	marker(1, mcolor("0 0 139")) marker(2, mcolor("0 0 139")) marker(3, mcolor("0 0 139")) marker(4, mcolor("0 0 139")) ///
	ytitle("Percentage Point", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ///
	ylabel(, labcolor(black) tlcolor("0 0 139") glcolor("104 34 139" %15)) ///
	yvaroptions(axis(lcolor("0 0 139") lwidth(medthick))) ///
	legend(label(1 "1 and 2") label(2 "1 and 3") label(3 "1 and 4") label(4 "1 and 5") rows(1) region(lcolor("0 0 139") lwidth(medium))) ///
	graphregion(color(white)) plotregion(color(white)) ///
	title("Under 20")
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_u20.gph", replace	
	
graph ///
	box EC_measure2_u25_diff_m1 EC_measure3_u25_diff_m1 EC_measure4_u25_diff_m1, ///
	box(1, color("104 34 139")) box(2, color("24 116 205")) box(3, color("171 130 255"*1.5)) ///
	box(4, fcolor(none)) ///
	marker(1, mcolor("0 0 139")) marker(2, mcolor("0 0 139")) marker(3, mcolor("0 0 139")) marker(4, mcolor("0 0 139")) ///
	ytitle("Percentage Point", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ///
	ylabel(, labcolor(black) tlcolor("0 0 139") glcolor("104 34 139" %15)) ///
	yvaroptions(axis(lcolor("0 0 139") lwidth(medthick))) ///
	legend(label(1 "1 and 2") label(2 "1 and 3") label(3 "1 and 4") label(4 "1 and 5") rows(1) region(lcolor("0 0 139") lwidth(medium))) ///
	graphregion(color(white)) plotregion(color(white)) ///
	title("Under 25")
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_u25.gph", replace		
	
graph combine "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_married" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_umsa" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_u20" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_u25", ///
	rows(2) xsize(7) ysize(4) graphregion(color(white)) plotregion(color(white))
	
		graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_combined", replace
		graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2019.03.07/Graph3.5_combined.pdf", replace
assert 0
	
*Graph 4

use "data_with_ci.dta", clear

tempfile all
preserve
collapse (mean) EC_measure1 ///
				lb_EC_measure1 ub_EC_measure1 se_EC_measure1 ///
				[pw=FQweight], by (country_v2)
save `all', replace
restore

tempfile married
preserve	
collapse (mean) EC_measure1 ///
				lb_married_EC_measure1 ub_married_EC_measure1 se_married_EC_measure1 ///
				[pw=FQweight] if married==1, by(country_v2)
	rename EC_measure1 EC_measure1_married
	rename lb_married_EC_measure1 lb_EC_measure1_married
	rename ub_married_EC_measure1 ub_EC_measure1_married
	rename se_married_EC_measure1 se_EC_measure1_married	
save `married', replace
restore

tempfile umsa
preserve	
collapse (mean) EC_measure1 ///
				lb_umsexactive_EC_measure1 ub_umsexactive_EC_measure1 se_umsexactive_EC_measure1 ///
				[pw=FQweight] if umsexactive==1, by(country_v2)
	rename EC_measure1 EC_measure1_umsexactive
	rename lb_umsexactive_EC_measure1 lb_EC_measure1_umsexactive
	rename ub_umsexactive_EC_measure1 ub_EC_measure1_umsexactive
	rename se_umsexactive_EC_measure1 se_EC_measure1_umsexactive	
save `umsa', replace
restore

tempfile u20
preserve	
collapse (mean) EC_measure1 ///
				lb_u20_EC_measure1 ub_u20_EC_measure1 se_u20_EC_measure1 ///
				[pw=FQweight] if u20==1, by(country_v2)
	rename EC_measure1 EC_measure1_u20
	rename lb_u20_EC_measure1 lb_EC_measure1_u20
	rename ub_u20_EC_measure1 ub_EC_measure1_u20
	rename se_u20_EC_measure1 se_EC_measure1_u20	
save `u20', replace
restore

tempfile u25
preserve	
collapse (mean) EC_measure1 ///
				lb_u25_EC_measure1 ub_u25_EC_measure1 se_u25_EC_measure1 ///
				[pw=FQweight] if u25==1, by(country_v2)
	rename EC_measure1 EC_measure1_u25
	rename lb_u25_EC_measure1 lb_EC_measure1_u25
	rename ub_u25_EC_measure1 ub_EC_measure1_u25
	rename se_u25_EC_measure1 se_EC_measure1_u25	
save `u25', replace
restore

use `all', clear
merge 1:1 country_v2 using `married', gen(married_merge)
merge 1:1 country_v2 using `umsa', gen(umsa_merge)
merge 1:1 country_v2 using `u20', gen(u20_merge)
merge 1:1 country_v2 using `u25', gen(u25_merge)

drop *merge

gen EC_measure1_percent=EC_measure1*100
gen se_EC_measure1_percent=se_EC_measure1*100
gen lb_EC_measure1_percent=lb_EC_measure1*100
gen ub_EC_measure1_percent=ub_EC_measure1*100

foreach subgroup in `subgroup_list' {
	gen EC_measure1_`subgroup'_perc=EC_measure1_`subgroup'*100
	gen se_EC_measure1_`subgroup'_perc=se_EC_measure1_`subgroup'*100
	gen lb_EC_measure1_`subgroup'_perc=lb_EC_measure1_`subgroup'*100
	gen ub_EC_measure1_`subgroup'_perc=ub_EC_measure1_`subgroup'*100
	}	
	
foreach country in 1 8 17 {
	preserve
	keep if country_v2==`country'

	expand 5 in 1
	local country: label country_label `country'
	
	gen measures=1
		replace measures=2 in 2
		replace measures=3 in 3
		replace measures=4 in 4
		replace measures=5 in 5
	gen EC_measure=.
		replace EC_measure=EC_measure1_percent if measures==1
		replace EC_measure=EC_measure1_married_perc if measures==2
		replace EC_measure=EC_measure1_umsexactive_perc if measures==3
		replace EC_measure=EC_measure1_u20_perc if measures==4
		replace EC_measure=EC_measure1_u25_perc if measures==5
	gen EC_measure_ub=.
		replace EC_measure_ub=ub_EC_measure1_percent if measures==1
		replace EC_measure_ub=ub_EC_measure1_married_perc if measures==2
		replace EC_measure_ub=ub_EC_measure1_umsexactive_perc if measures==3
		replace EC_measure_ub=ub_EC_measure1_u20_perc if measures==4
		replace EC_measure_ub=ub_EC_measure1_u25_perc if measures==5
	gen EC_measure_lb=.
		replace EC_measure_lb=lb_EC_measure1_percent if measures==1
		replace EC_measure_lb=lb_EC_measure1_married_perc if measures==2
		replace EC_measure_lb=lb_EC_measure1_umsexactive_perc if measures==3
		replace EC_measure_lb=lb_EC_measure1_u20_perc if measures==4
		replace EC_measure_lb=lb_EC_measure1_u25_perc if measures==5

	format EC_measure %2.1f	
		
	if country_v2==1 {		
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ytick(0(.5)5.5) ylabel(0(1)5.5, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "All" 2 "In Union" 3 "Unmarried Sexually Active" 4 "Under 20" 5 "Under 25" 5.5 " ", labsize(small)) xtitle("Burkina Faso", size(medlarge)) ///
			xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
	
	if country_v2==8 {
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ytick(0(.5)5.5) ylabel(0(1)5.5, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "All" 2 "In Union" 3 "Unmarried Sexually Active" 4 "Under 20" 5 "Under 25" 5.5 " ", labsize(small)) xtitle("Kenya", size(medlarge)) ///
			xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
		
	if country_v2==17 {
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ytick(0(.5)5.5) ylabel(0(1)5.5, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "All" 2 "In Union" 3 "Unmarried Sexually Active" 4 "Under 20" 5 "Under 25" 5.5 " ", labsize(small)) xtitle("Uganda", size(medlarge)) ///
			xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
		
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph4_`country'.gph", replace
		
	restore
	}
	
graph combine "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph4_Burkina Faso" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph4_Kenya" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph4_Uganda", ///
	rows(1) xsize(10) graphregion(color(white)) plotregion(color(white))
	*ycommon title("Definition 1 by subgroup for Burkina Faso, Kenya, and Uganda") subtitle("Percent Estimate and 95% Confidence Interval")
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph4_combined", replace
	graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph4_combined.pdf", replace


*Graph 5	

use "data_with_ci.dta", clear

tempfile graph1_2
collapse (mean) `measure_list3' ///
				se* lb* ub*  ///
				[pw=FQweight], by(country_v2)			
				
foreach measure in `measure_list3' {
	gen `measure'_percent=`measure'*100
	gen se_`measure'_percent=se_`measure'*100
	gen lb_`measure'_percent=lb_`measure'*100
	gen ub_`measure'_percent=ub_`measure'*100
	}

save `graph1_2', replace
use `graph1_2', clear	

foreach country in 1 8 17 {
	preserve
	keep if country_v2==`country'
	expand 5 in 1
	
	local country: label country_label `country'
	
	gen measures=1
		replace measures=2 in 2
		replace measures=3 in 3
		replace measures=4 in 4
		replace measures=5 in 5
	gen EC_measure=.
		replace EC_measure=EC_measure1_percent if measures==1
		replace EC_measure=EC_measure2_percent if measures==2
		replace EC_measure=EC_measure3_percent if measures==3
		replace EC_measure=EC_measure4_percent if measures==4
		replace EC_measure=EC_measure5_percent if measures==5
	gen EC_measure_ub=.
		replace EC_measure_ub=ub_EC_measure1_percent if measures==1
		replace EC_measure_ub=ub_EC_measure2_percent if measures==2
		replace EC_measure_ub=ub_EC_measure3_percent if measures==3
		replace EC_measure_ub=ub_EC_measure4_percent if measures==4	
		replace EC_measure_ub=ub_EC_measure5_percent if measures==5
	gen EC_measure_lb=.
		replace EC_measure_lb=lb_EC_measure1_percent if measures==1
		replace EC_measure_lb=lb_EC_measure2_percent if measures==2
		replace EC_measure_lb=lb_EC_measure3_percent if measures==3
		replace EC_measure_lb=lb_EC_measure4_percent if measures==4	
		replace EC_measure_lb=lb_EC_measure5_percent if measures==5

	format EC_measure %2.1f	
		
	if country_v2==1 {	
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ylabel(0(1)9, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(range(0,9) lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "Definition 1" 2 "Definition 2" 3 "Definition 3" 4 "Definition 4" 5 "Definition 5" 5.5 " ") xtitle("Burkina Faso", size(medlarge)) xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
	
	if country_v2==8 {
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ylabel(0(1)9, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(range(0,9) lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "Definition 1" 2 "Definition 2" 3 "Definition 3" 4 "Definition 4" 5 "Definition 5" 5.5 " ") xtitle("Kenya", size(medlarge)) xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
		
	if country_v2==17 {
		twoway ///
			rcap EC_measure_ub EC_measure_lb measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure measures, ///
				mcolor("0 0 139") ///
			ylabel(0(1)9, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(range(0,9) lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "Definition 1" 2 "Definition 2" 3 "Definition 3" 4 "Definition 4" 5 "Definition 5" 5.5 " ") xtitle("Uganda", size(medlarge)) xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}


	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph5_`country'.gph", replace
	
	
	restore
	}

graph combine "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph5_Burkina Faso" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph5_Kenya" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph5_Uganda", ///
	rows(1) xsize(10) graphregion(color(white)) plotregion(color(white))
	*ycommon title("Definitions 1-4 for Burkina Faso, Kenya, and Uganda") subtitle("Percent Estimate and 95% Confidence Interval")
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/ICFP/Graph5_combined", replace
	graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/ICFP/Graph5_combined.pdf", replace

	
* Graph 6
use "data_with_ci.dta", clear


tempfile all
preserve
collapse (mean) EC_measure1 EC_measure5 ///
				lb_EC_measure1 ub_EC_measure1 se_EC_measure1 ///
				lb_EC_measure5 ub_EC_measure5 se_EC_measure5 ///
				[pw=FQweight], by (country_v2)
save `all', replace
restore

tempfile married
preserve	
collapse (mean) EC_measure1 EC_measure5 ///
				lb_married_EC_measure1 ub_married_EC_measure1 se_married_EC_measure1 ///
				lb_married_EC_measure5 ub_married_EC_measure5 se_married_EC_measure5 ///
				[pw=FQweight] if married==1, by(country_v2)
	rename EC_measure1 EC_measure1_married
	rename lb_married_EC_measure1 lb_EC_measure1_married
	rename ub_married_EC_measure1 ub_EC_measure1_married
	rename se_married_EC_measure1 se_EC_measure1_married
	rename EC_measure5 EC_measure5_married
	rename lb_married_EC_measure5 lb_EC_measure5_married
	rename ub_married_EC_measure5 ub_EC_measure5_married
	rename se_married_EC_measure5 se_EC_measure5_married	
save `married', replace
restore

tempfile umsa
preserve	
collapse (mean) EC_measure1 EC_measure5 ///
				lb_umsexactive_EC_measure1 ub_umsexactive_EC_measure1 se_umsexactive_EC_measure1 ///
				lb_umsexactive_EC_measure5 ub_umsexactive_EC_measure5 se_umsexactive_EC_measure5 ///
				[pw=FQweight] if umsexactive==1, by(country_v2)
	rename EC_measure1 EC_measure1_umsexactive
	rename lb_umsexactive_EC_measure1 lb_EC_measure1_umsexactive
	rename ub_umsexactive_EC_measure1 ub_EC_measure1_umsexactive
	rename se_umsexactive_EC_measure1 se_EC_measure1_umsexactive	
	rename EC_measure5 EC_measure5_umsexactive
	rename lb_umsexactive_EC_measure5 lb_EC_measure5_umsexactive
	rename ub_umsexactive_EC_measure5 ub_EC_measure5_umsexactive
	rename se_umsexactive_EC_measure5 se_EC_measure5_umsexactive	
save `umsa', replace
restore

tempfile u20
preserve	
collapse (mean) EC_measure1 EC_measure5 ///
				lb_u20_EC_measure1 ub_u20_EC_measure1 se_u20_EC_measure1 ///
				lb_u20_EC_measure5 ub_u20_EC_measure5 se_u20_EC_measure5 ///
				[pw=FQweight] if u20==1, by(country_v2)
	rename EC_measure1 EC_measure1_u20
	rename lb_u20_EC_measure1 lb_EC_measure1_u20
	rename ub_u20_EC_measure1 ub_EC_measure1_u20
	rename se_u20_EC_measure1 se_EC_measure1_u20	
	rename EC_measure5 EC_measure5_u20
	rename lb_u20_EC_measure5 lb_EC_measure5_u20
	rename ub_u20_EC_measure5 ub_EC_measure5_u20
	rename se_u20_EC_measure5 se_EC_measure5_u20	
save `u20', replace
restore

tempfile u25
preserve	
collapse (mean) EC_measure1 EC_measure5 ///
				lb_u25_EC_measure1 ub_u25_EC_measure1 se_u25_EC_measure1 ///
				lb_u25_EC_measure5 ub_u25_EC_measure5 se_u25_EC_measure5 ///
				[pw=FQweight] if u25==1, by(country_v2)
	rename EC_measure1 EC_measure1_u25
	rename lb_u25_EC_measure1 lb_EC_measure1_u25
	rename ub_u25_EC_measure1 ub_EC_measure1_u25
	rename se_u25_EC_measure1 se_EC_measure1_u25	
	rename EC_measure5 EC_measure5_u25
	rename lb_u25_EC_measure5 lb_EC_measure5_u25
	rename ub_u25_EC_measure5 ub_EC_measure5_u25
	rename se_u25_EC_measure5 se_EC_measure5_u25	
save `u25', replace
restore

use `all', clear
merge 1:1 country_v2 using `married', gen(married_merge)
merge 1:1 country_v2 using `umsa', gen(umsa_merge)
merge 1:1 country_v2 using `u20', gen(u20_merge)
merge 1:1 country_v2 using `u25', gen(u25_merge)

drop *merge

gen EC_measure1_percent=EC_measure1*100
gen se_EC_measure1_percent=se_EC_measure1*100
gen lb_EC_measure1_percent=lb_EC_measure1*100
gen ub_EC_measure1_percent=ub_EC_measure1*100

gen EC_measure5_percent=EC_measure5*100
gen se_EC_measure5_percent=se_EC_measure5*100
gen lb_EC_measure5_percent=lb_EC_measure5*100
gen ub_EC_measure5_percent=ub_EC_measure5*100

foreach subgroup in `subgroup_list' {
	gen EC_measure1_`subgroup'_perc=EC_measure1_`subgroup'*100
	gen se_EC_measure1_`subgroup'_perc=se_EC_measure1_`subgroup'*100
	gen lb_EC_measure1_`subgroup'_perc=lb_EC_measure1_`subgroup'*100
	gen ub_EC_measure1_`subgroup'_perc=ub_EC_measure1_`subgroup'*100
	}	
	
foreach subgroup in `subgroup_list' {
	gen EC_measure5_`subgroup'_perc=EC_measure5_`subgroup'*100
	gen se_EC_measure5_`subgroup'_perc=se_EC_measure5_`subgroup'*100
	gen lb_EC_measure5_`subgroup'_perc=lb_EC_measure5_`subgroup'*100
	gen ub_EC_measure5_`subgroup'_perc=ub_EC_measure5_`subgroup'*100
	}	
	
foreach country in 1 8 17 {
	preserve
	keep if country_v2==`country'

	expand 5 in 1
	local country: label country_label `country'
	
	drop EC_measure1 EC_measure5
	
	gen measures=1
		replace measures=2 in 2
		replace measures=3 in 3
		replace measures=4 in 4
		replace measures=5 in 5
	gen EC_measure1=.
		replace EC_measure1=EC_measure1_percent if measures==1
		replace EC_measure1=EC_measure1_married_perc if measures==2
		replace EC_measure1=EC_measure1_umsexactive_perc if measures==3
		replace EC_measure1=EC_measure1_u20_perc if measures==4
		replace EC_measure1=EC_measure1_u25_perc if measures==5
	gen EC_measure_ub1=.
		replace EC_measure_ub1=ub_EC_measure1_percent if measures==1
		replace EC_measure_ub1=ub_EC_measure1_married_perc if measures==2
		replace EC_measure_ub1=ub_EC_measure1_umsexactive_perc if measures==3
		replace EC_measure_ub1=ub_EC_measure1_u20_perc if measures==4
		replace EC_measure_ub1=ub_EC_measure1_u25_perc if measures==5
	gen EC_measure_lb1=.
		replace EC_measure_lb1=lb_EC_measure1_percent if measures==1
		replace EC_measure_lb1=lb_EC_measure1_married_perc if measures==2
		replace EC_measure_lb1=lb_EC_measure1_umsexactive_perc if measures==3
		replace EC_measure_lb1=lb_EC_measure1_u20_perc if measures==4
		replace EC_measure_lb1=lb_EC_measure1_u25_perc if measures==5
	gen EC_measure5=.
		replace EC_measure5=EC_measure5_percent if measures==1
		replace EC_measure5=EC_measure5_married_perc if measures==2
		replace EC_measure5=EC_measure5_umsexactive_perc if measures==3
		replace EC_measure5=EC_measure5_u20_perc if measures==4
		replace EC_measure5=EC_measure5_u25_perc if measures==5
	gen EC_measure_ub5=.
		replace EC_measure_ub5=ub_EC_measure5_percent if measures==1
		replace EC_measure_ub5=ub_EC_measure5_married_perc if measures==2
		replace EC_measure_ub5=ub_EC_measure5_umsexactive_perc if measures==3
		replace EC_measure_ub5=ub_EC_measure5_u20_perc if measures==4
		replace EC_measure_ub5=ub_EC_measure5_u25_perc if measures==5
	gen EC_measure_lb5=.
		replace EC_measure_lb5=lb_EC_measure5_percent if measures==1
		replace EC_measure_lb5=lb_EC_measure5_married_perc if measures==2
		replace EC_measure_lb5=lb_EC_measure5_umsexactive_perc if measures==3
		replace EC_measure_lb5=lb_EC_measure5_u20_perc if measures==4
		replace EC_measure_lb5=lb_EC_measure5_u25_perc if measures==5

	format EC_measure1 EC_measure5 %2.1f	
		
	if country_v2==1 {		
		twoway ///
			rcap EC_measure_ub1 EC_measure_lb1 measures, ///
				lcolor("104 34 139 %40") lwidth(medthick) || ///			
			rcap EC_measure_ub5 EC_measure_lb5 measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure1 measures, ///
				mcolor("0 0 139 %40") || ///
			scatter EC_measure5 measures, ///
				mcolor("0 0 139") ///
			ytick(0(1)17) yscale(range(0,17)) ylabel(0(2)17, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "All" 2 "In Union" 3 "Unmarried Sexually Active" 4 "Under 20" 5 "Under 25" 5.5 " ", labsize(small)) xtitle("Burkina Faso", size(medlarge)) ///
			xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
	
	if country_v2==8 {
		twoway ///
			rcap EC_measure_ub1 EC_measure_lb1 measures, ///
				lcolor("104 34 139 %40") lwidth(medthick) || ///
			rcap EC_measure_ub5 EC_measure_lb5 measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure1 measures, ///
				mcolor("0 0 139 %40") || ///
			scatter EC_measure5 measures, ///
				mcolor("0 0 139") ///
			ytick(0(1)17) yscale(range(0,17)) ylabel(0(2)17, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "All" 2 "In Union" 3 "Unmarried Sexually Active" 4 "Under 20" 5 "Under 25" 5.5 " ", labsize(small)) xtitle("Kenya", size(medlarge)) ///
			xscale(lwidth(medthick) lcolor("0 0 139")) ///
			legend(off) graphregion(color(white)) plotregion(color(white))
		}
		
	if country_v2==17 {
		twoway ///
			rcap EC_measure_ub1 EC_measure_lb1 measures, ///
				lcolor("104 34 139 %50") lwidth(medthick) || ///
			rcap EC_measure_ub5 EC_measure_lb5 measures, ///
				lcolor("104 34 139") lwidth(medthick) || ///
			scatter EC_measure1 measures, ///
				mcolor("0 0 139 %50") || ///
			scatter EC_measure5 measures, ///
				mcolor("0 0 139") ///
			ytick(0(1)17) yscale(range(0,17)) ylabel(0(2)17, tlcolor("0 0 139") glcolor("104 34 139" %15)) ytitle("Percent", color(black)) yscale(lwidth(medthick) lcolor("0 0 139")) ysize(4) ///
			xlabel(0.5(1)5.5, noticks angle(45)) ///
			xlabel(0.5 " " 1 "All" 2 "In Union" 3 "Unmarried Sexually Active" 4 "Under 20" 5 "Under 25" 5.5 " ", labsize(small)) xtitle("Uganda", size(medlarge)) ///
			xscale(lwidth(medthick) lcolor("0 0 139")) ///
			graphregion(color(white)) plotregion(color(white)) ///
			legend(label(1 "95% CI") label(2 "95% CI") label(3 "Definition 1") label(4 "Definition 5") rows(2) position(2) ring(0) size(vsmall) region(lcolor("0 0 139") lwidth(medium)))	///
			legend(order(4 2 3 1))
		}
		
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph6_`country'.gph", replace
		
	restore
	}
	
graph combine "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph6_Burkina Faso" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph6_Kenya" ///
	"/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph6_Uganda", ///
	rows(1) xsize(10) graphregion(color(white)) plotregion(color(white))
	*ycommon title("Definition 1 by subgroup for Burkina Faso, Kenya, and Uganda") subtitle("Percent Estimate and 95% Confidence Interval")
	
	graph save "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph6_combined", replace
	graph export "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/Report Draft/Graphs_2018.11.28/Graph6_combined.pdf", replace

	

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

local measure_list "measure1 measure2 measure3 measure4"
local measure_list2 "measure1 measure2 measure3 measure4 measure5"

local subgroup_list "married umsexactive u20 u25"

local tabout_excel "$resultsdir/ECAnalysis_Tabouts_v2_$date.xls"
local excel_paper_2 "$resultsdir/ECAnalysis_PaperTablesv2_$date.xls"
local excel "$resultsdir/ECAnalysis_PutExcel.xls"

cd "$ECfolder"
log using "$ECfolder/log_files/PMA2020_ECMethodology_$date.log", replace
use "`datadir'/ECdata_v2.dta"

********************************************************************************
*Section A. Data Prep
********************************************************************************
label define yes_no 0 "0. No" 1 "1. Yes"

**Generate EC Variables**
gen measure1=0
replace measure1=1 if current_methodnum==8
label val measure1 yes_no

gen measure2=0
replace measure2=1 if EC==1 //gen byte x=EC==1
label val measure2 yes_no

gen measure3=0
replace measure3=1 if current_methodnum==8 | recent_methodnum==8
label val measure3 yes_no

gen measure4=0
replace measure4=1 if EC==1 | recent_methodnum==8
label val measure4 yes_no

gen measure5=0
replace measure5=1 if EC==1 & (country=="BF" | country=="KE" | country=="UG")
replace measure5=1 if emergency_12mo_yn==1 & (country=="BF" | country=="KE" | country=="UG")
label val measure5 yes_no

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

*******BY COUNTRY*******
foreach country in `country_list' {
	foreach subgroup in married umsexactive {
		tab country [aw=FQweight] if country=="`country'"
			matrix all=r(N)
		tab `subgroup' [aw=FQweight] if country=="`country'", matcell(reference)
			matrix `subgroup'_count=reference[2,1]
		mean `subgroup' [aw=FQweight] if country=="`country'"
			matrix reference=r(table)
			matrix `subgroup'_percent=reference[1,1]*100
			matrix `subgroup'_ll=reference[5,1]*100
			matrix `subgroup'_ul=reference[6,1]*100
		}
	
	foreach age in 15 20 25 30 35 40 45 {
		tab age5 [aw=FQweight] if country=="`country'"
			matrix count=r(N)
		tab age5 [aw=FQweight] if country=="`country'" & age5==`age', matcell(reference)
			matrix age`age'_count=reference[1,1] 
		}
		
		svy: prop age5 if country=="`country'"
			matrix reference=r(table)
			matrix age15_percent=reference[1,1]*100
				matrix age15_ll=reference[5,1]*100
				matrix age15_ul=reference[6,1]*100
			matrix age20_percent=reference[1,2]*100
				matrix age20_ll=reference[5,2]*100
				matrix age20_ul=reference[6,2]*100
			matrix age25_percent=reference[1,3]*100
				matrix age25_ll=reference[5,3]*100
				matrix age25_ul=reference[6,3]*100
			matrix age30_percent=reference[1,4]*100
				matrix age30_ll=reference[5,4]*100
				matrix age30_ul=reference[6,4]*100
			matrix age35_percent=reference[1,5]*100
				matrix age35_ll=reference[5,5]*100
				matrix age35_ul=reference[6,5]*100
			matrix age40_percent=reference[1,6]*100
				matrix age40_ll=reference[5,6]*100
				matrix age40_ul=reference[6,6]*100
			matrix age45_percent=reference[1,7]*100
				matrix age45_ll=reference[5,7]*100
				matrix age45_ul=reference[6,7]*100

	putexcel set "`excel'", modify sheet("`country'")
				
	putexcel A1="Background Characteristics"
		putexcel A2="Subgroup"
		putexcel B2="Sample Size"
		putexcel C2="Percent"
		putexcel E2="CI, LL"
		putexcel F2="CI, UL"
	putexcel A3="All Women"
		putexcel A4="Married"
		putexcel A5="Unmarried Sexually Active"
		putexcel A6="15-19"
		putexcel A7="20-24"
		putexcel A8="25-29"
		putexcel A9="30-34"
		putexcel A10="35-39"
		putexcel A11="40-44"
		putexcel A12="45-49"
	putexcel B3=matrix(all)
	putexcel B4=matrix(married_count)
		putexcel C4=matrix(married_percent)
		putexcel E4=matrix(married_ll)
		putexcel F4=matrix(married_ul)
	putexcel B5=matrix(umsexactive_count)
		putexcel C5=matrix(umsexactive_percent)
		putexcel E5=matrix(umsexactive_ll)
		putexcel F5=matrix(umsexactive_ul)
	putexcel B6=matrix(age15_count)
		putexcel C6=matrix(age15_percent)
		putexcel E6=matrix(age15_ll)
		putexcel F6=matrix(age15_ul)
	putexcel B7=matrix(age20_count)
		putexcel C7=matrix(age20_percent)
		putexcel E7=matrix(age20_ll)
		putexcel F7=matrix(age20_ul)
	putexcel B8=matrix(age25_count)
		putexcel C8=matrix(age25_percent)
		putexcel E8=matrix(age25_ll)
		putexcel F8=matrix(age25_ul)
	putexcel B9=matrix(age30_count)
		putexcel C9=matrix(age30_percent)
		putexcel E9=matrix(age30_ll)
		putexcel F9=matrix(age30_ul)
	putexcel B10=matrix(age35_count)
		putexcel C10=matrix(age35_percent)
		putexcel E10=matrix(age35_ll)
		putexcel F10=matrix(age35_ul)
	putexcel B11=matrix(age40_count)
		putexcel C11=matrix(age40_percent)
		putexcel E11=matrix(age40_ll)
		putexcel F11=matrix(age40_ul)
	putexcel B12=matrix(age45_count)
		putexcel C12=matrix(age45_percent)
		putexcel E12=matrix(age45_ll)
		putexcel F12=matrix(age45_ul)	
	
	}

*******AVERAGE*******
	
preserve

collapse (count) all_count=one married_count=married umsexactive_count=umsexactive ///
		 (mean) all_mean=one married_mean=married umsexactive_mean=umsexactive, ///
		 by(country)

mean all_count
matrix reference=r(table)
	matrix all=reference[1,1]

foreach demographic in married umsexactive {
	mean `demographic'_mean
	matrix reference=r(table)
		matrix `demographic'_percent=reference[1,1]*100
	}

putexcel set "`excel'", modify sheet("Average")

putexcel A1="Background Characteristics"
	putexcel A2="Subgroup"
	putexcel B2="Sample Size"
	putexcel C2="Percent"
putexcel A3="All Women"
	putexcel A4="Married"
	putexcel A5="Unmarried Sexually Active"
putexcel B3=matrix(all)
	putexcel C4=matrix(married_percent)
	putexcel C5=matrix(umsexactive_percent)
	
restore

preserve

collapse (count) married_count=married if married==1, by(country)

mean married_count
matrix reference=r(table)
	matrix married_count=reference[1,1]

putexcel set "`excel'", modify sheet("Average")	
	
putexcel B4=matrix(married_count)

restore

preserve

collapse (count) umsexactive_count=umsexactive if umsexactive==1, by(country)

mean umsexactive_count
matrix reference=r(table)
	matrix umsexactive_count=reference[1,1]
	
putexcel set "`excel'", modify sheet("Average")	

putexcel B5=matrix(umsexactive_count)

restore
	
preserve
		
collapse (count) FQ_age_count=FQ_age ///
	     (mean) FQ_age_mean=FQ_age, by(country age5)
collapse (mean) FQ_age_count FQ_age_mean, by(age5)

foreach age in 15 20 25 30 35 40 45 {
	mean FQ_age_count if age5==`age'
	matrix reference=r(table)
		matrix age`age'_count=reference[1,1]
	mean FQ_age_mean if age5==`age'
	matrix reference=r(table)
		matrix age`age'_mean=reference[1,1]
	}

putexcel set "`excel'", modify sheet("Average")

putexcel A6="15-19"
	putexcel A7="20-24"
	putexcel A8="25-29"
	putexcel A9="30-34"
	putexcel A10="35-39"
	putexcel A11="40-44"
	putexcel A12="45-49"
putexcel B6=matrix(age15_count)
	putexcel C6=matrix(age15_mean)
putexcel B7=matrix(age20_count)
	putexcel C7=matrix(age20_mean)
putexcel B8=matrix(age25_count)
	putexcel C8=matrix(age25_mean)
putexcel B9=matrix(age30_count)
	putexcel C9=matrix(age30_mean)
putexcel B10=matrix(age35_count)
	putexcel C10=matrix(age35_mean)
putexcel B11=matrix(age40_count)
	putexcel C11=matrix(age40_mean)
putexcel B12=matrix(age45_count)
	putexcel C12=matrix(age45_mean)
	
restore

********************************************************************************
*Section C. Tables
********************************************************************************
*Appendix 2
*******BY COUNTRY*******
foreach country in `country_list' {
	foreach measure in `measure_list' {
		tab country if country=="`country'"
			matrix all=r(N)
		svy:prop `measure' if country=="`country'", citype(wilson)
			matrix reference=r(table)
			matrix `measure'_percent=reference[1,2]*100
			matrix `measure'_ll=reference[5,2]*100
			matrix `measure'_ul=reference[6,2]*100
	}

	putexcel set "`excel'", modify sheet("`country'")
	
	putexcel A14="Appendix 2"
		putexcel C15="Definition 1"
		putexcel G15="Definition 2"
		putexcel K15="Definition 3"
		putexcel O15="Definition 4"
	putexcel A16="Country"
		putexcel B16="N"
		putexcel C16="Percent"
		putexcel E16="CI, LL"
		putexcel F16="CI, UL"
		putexcel G16="Percent"
		putexcel I16="CI, LL"
		putexcel J16="CI, UL"
		putexcel K16="Percent"
		putexcel M16="CI, LL"
		putexcel N16="CI, UL"
		putexcel O16="Percent"
		putexcel Q16="CI, LL"
		putexcel R16="CI, UL"
	putexcel A17="`country'"
		putexcel B17=matrix(all)
		putexcel C17=matrix(measure1_percent)
		putexcel E17=matrix(measure1_ll)
		putexcel F17=matrix(measure1_ul)
		putexcel G17=matrix(measure2_percent)
		putexcel I17=matrix(measure2_ll)
		putexcel J17=matrix(measure2_ul)
		putexcel K17=matrix(measure3_percent)
		putexcel M17=matrix(measure3_ll)
		putexcel N17=matrix(measure3_ul)
		putexcel O17=matrix(measure4_percent)
		putexcel Q17=matrix(measure4_ll)
		putexcel R17=matrix(measure4_ul)
	
	}

	assert 0
*******AVERAGE*******
preserve

collapse (count) measure1_count=measure1 measure2_count=measure2 measure3_count=measure3 measure4_count=measure4 ///
		 (mean) measure1_mean=measure1 measure2_mean=measure2 measure3_mean=measure3 measure4_mean=measure4 [pw=FQweight], ///
		 by(country)
		 
foreach measure in `measure_list' {
	mean `measure'_count
	matrix reference=r(table)
		matrix `measure'_count=reference[1,1]
	mean `measure'_mean
	matrix reference=r(table)
		matrix `measure'_percent=reference[1,1]*100
	egen `measure'_sd=sd(`measure'_mean)
	mean `measure'_sd
	matrix reference=r(table)
		matrix `measure'_sd=reference[1,1]*100
	}
	
putexcel set "`excel'", modify sheet("Average")

	putexcel A14="Appendix 2"
		putexcel C15="Definition 1"
		putexcel E15="Definition 2"
		putexcel G15="Definition 3"
		putexcel I15="Definition 4"
	putexcel A16="Average"
		putexcel B16="N"
		putexcel C16="Percent"
		putexcel D16="Standard Deviation"
		putexcel E16="Percent"
		putexcel F16="Standard Deviation"
		putexcel G16="Percent"
		putexcel H16="Standard Deviation"
		putexcel I16="Percent"
		putexcel J16="Standard Deviation"
	putexcel B17=matrix(measure1_count)
	putexcel C17=matrix(measure1_percent)
		putexcel D17=matrix(measure1_sd)
	putexcel E17=matrix(measure2_percent)
		putexcel F17=matrix(measure2_sd)
	putexcel G17=matrix(measure3_percent)
		putexcel H17=matrix(measure3_sd)
	putexcel I17=matrix(measure4_percent)
		putexcel J17=matrix(measure4_sd)
		
restore


	
*Appendix 3*
*******BY COUNTRY*******
preserve

collapse (mean) `measure_list' [pw=FQweight], by(country)

foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent-measure1_percent
	}
	
drop `measure_list' 
drop measure2_percent measure3_percent measure4_percent
drop measure1_diff_measure1

foreach country in `country_list' {
	
	putexcel set "`excel'", modify sheet("`country'")
	
	putexcel A19="Appendix 3"
		putexcel A20="Country"
		putexcel B20="Definition 1 (Actual)"
		putexcel C20="Definition 2"
		putexcel D20="Definition 3"
		putexcel E20="Definition 4"

	export excel using "`excel'" if country=="`country'", sheet("`country'", modify) cell(A21)
	
	}

restore


*******AVERAGE*******
preserve

collapse (mean) `measure_list' [pw=FQweight], by(country)

foreach measure in `measure_list' {
	gen `measure'_percent=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent-measure1_percent
	}
	
drop `measure_list' 
drop measure2_percent measure3_percent measure4_percent
drop measure1_diff_measure1

mean measure1
matrix reference=r(table)
	matrix measure1_mean=reference[1,1]
	
foreach n of numlist 2/4 {
	mean measure`n'_diff_measure1
	matrix reference=r(table)
		matrix measure`n'_diff_mean=reference[1,1]
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel A19="Appendix 3"
	putexcel A20="Definition 1 (Actual)"
	putexcel B20="Definition 2"
	putexcel C20="Definition 3"
	putexcel D20="Definition 4"
putexcel A21=matrix(measure1_mean)
	putexcel B21=matrix(measure2_diff_mean)
	putexcel C21=matrix(measure3_diff_mean)
	putexcel D21=matrix(measure4_diff_mean)

restore


*Appendix 4*
*******BY COUNTRY*******
foreach country in `country_list' {	
	foreach subgroup in `subgroup_list' {
		foreach measure in `measure_list' {
			tab country if country=="`country'" & `subgroup'==1
				matrix all_`subgroup'=r(N)
			svy:prop `measure' if country=="`country'" & `subgroup'==1, citype(wilson)
				matrix reference=r(table)
				matrix `subgroup'_`measure'_percent=reference[1,2]*100
				matrix `subgroup'_`measure'_ll=reference[5,2]*100
				matrix `subgroup'_`measure'_ul=reference[6,2]*100
			}
		}
		
	putexcel set "`excel'", modify sheet("`country'")
	
	putexcel A23="Appendix 4"
		putexcel D24="Definition 1"
		putexcel H24="Definition 2"
		putexcel L24="Definition 3"
		putexcel P24="Definition 4"
	putexcel A25="Country"
		putexcel B25="Subgroup"
		putexcel C25="N"
		putexcel D25="Percent"
		putexcel F25="CI, LL"
		putexcel G25="CI, UL"
		putexcel H25="Percent"
		putexcel J25="CI, LL"
		putexcel K25="CI, UL"
		putexcel L25="Percent"
		putexcel N25="CI, LL"
		putexcel O25="CI, UL"
		putexcel P25="Percent"
		putexcel R25="CI, LL"
		putexcel S25="CI, UL"
	putexcel A26="`country'"
		putexcel B26="Married"
			putexcel C26=matrix(all_married)
			putexcel D26=matrix(married_measure1_percent)
			putexcel F26=matrix(married_measure1_ll)
			putexcel G26=matrix(married_measure1_ul)
			putexcel H26=matrix(married_measure2_percent)
			putexcel J26=matrix(married_measure2_ll)
			putexcel K26=matrix(married_measure2_ul)
			putexcel L26=matrix(married_measure3_percent)
			putexcel N26=matrix(married_measure3_ll)
			putexcel O26=matrix(married_measure3_ul)
			putexcel P26=matrix(married_measure4_percent)
			putexcel R26=matrix(married_measure4_ll)
			putexcel S26=matrix(married_measure4_ul)
		putexcel B27="Unmarried Sexually Active"
			putexcel C27=matrix(all_umsexactive)
			putexcel D27=matrix(umsexactive_measure1_percent)
			putexcel F27=matrix(umsexactive_measure1_ll)
			putexcel G27=matrix(umsexactive_measure1_ul)
			putexcel H27=matrix(umsexactive_measure2_percent)
			putexcel J27=matrix(umsexactive_measure2_ll)
			putexcel K27=matrix(umsexactive_measure2_ul)
			putexcel L27=matrix(umsexactive_measure3_percent)
			putexcel N27=matrix(umsexactive_measure3_ll)
			putexcel O27=matrix(umsexactive_measure3_ul)
			putexcel P27=matrix(umsexactive_measure4_percent)
			putexcel R27=matrix(umsexactive_measure4_ll)
			putexcel S27=matrix(umsexactive_measure4_ul)
		putexcel B28="Under 20"
			putexcel C28=matrix(all_u20)
			putexcel D28=matrix(u20_measure1_percent)
			putexcel F28=matrix(u20_measure1_ll)
			putexcel G28=matrix(u20_measure1_ul)
			putexcel H28=matrix(u20_measure2_percent)
			putexcel J28=matrix(u20_measure2_ll)
			putexcel K28=matrix(u20_measure2_ul)
			putexcel L28=matrix(u20_measure3_percent)
			putexcel N28=matrix(u20_measure3_ll)
			putexcel O28=matrix(u20_measure3_ul)
			putexcel P28=matrix(u20_measure4_percent)
			putexcel R28=matrix(u20_measure4_ll)
			putexcel S28=matrix(u20_measure4_ul)
		putexcel B29="Under 25"
			putexcel C29=matrix(all_u25)
			putexcel D29=matrix(u25_measure1_percent)
			putexcel F29=matrix(u25_measure1_ll)
			putexcel G29=matrix(u25_measure1_ul)
			putexcel H29=matrix(u25_measure2_percent)
			putexcel J29=matrix(u25_measure2_ll)
			putexcel K29=matrix(u25_measure2_ul)
			putexcel L29=matrix(u25_measure3_percent)
			putexcel N29=matrix(u25_measure3_ll)
			putexcel O29=matrix(u25_measure3_ul)
			putexcel P29=matrix(u25_measure4_percent)
			putexcel R29=matrix(u25_measure4_ll)
			putexcel S29=matrix(u25_measure4_ul)
			
	}

*******AVERAGE*******
preserve

collapse (count) married_count=married if married==1 [pw=FQweight], by(country)

mean married_count
matrix reference=r(table)
	matrix married_count=reference[1,1]
	
putexcel set "`excel'", modify sheet("Average")	

putexcel A23="Appendix 4"
	putexcel D24="Definition 1"
	putexcel F24="Definition 2"
	putexcel H24="Definition 3"
	putexcel J24="Definition 4"	 
putexcel A25="Country"
	putexcel B25="Subgroup"
	putexcel C25="N"
putexcel C26=matrix(married_count)

restore

preserve

collapse (count) measure1_count=measure1 measure2_count=measure2 measure3_count=measure3 measure4_count=measure4 ///
		 (mean) measure1_mean=measure1 measure2_mean=measure2 measure3_mean=measure3 measure4_mean=measure4 [pw=FQweight], ///
		 by(country married) 

foreach measure in `measure_list' {
	mean `measure'_mean if married==1
	matrix reference=r(table)
		matrix married_`measure'_percent=reference[1,1]*100
	egen married_`measure'_sd=sd(`measure'_mean) if married==1
	mean married_`measure'_sd
	matrix reference=r(table)
		matrix married_`measure'_sd=reference[1,1]*100
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel D25="Percent"
	putexcel E25="Standard Deviation"
	putexcel F25="Percent"
	putexcel G25="Standard Deviation"
	putexcel H25="Percent"
	putexcel I25="Standard Deviation"
	putexcel J25="Percent"
	putexcel K25="Standard Deviation"
putexcel A26="Average"
putexcel B26="Married"
	putexcel D26=matrix(married_measure1_percent)
	putexcel E26=matrix(married_measure1_sd)
	putexcel F26=matrix(married_measure2_percent)
	putexcel G26=matrix(married_measure2_sd)
	putexcel H26=matrix(married_measure3_percent)
	putexcel I26=matrix(married_measure3_sd)
	putexcel J26=matrix(married_measure4_percent)
	putexcel K26=matrix(married_measure4_sd)	
	
restore

preserve

collapse (count) umsexactive_count=umsexactive if umsexactive==1 [pw=FQweight], by(country)

mean umsexactive_count
matrix reference=r(table)
	matrix umsexactive_count=reference[1,1]
	
putexcel set "`excel'", modify sheet("Average")	

putexcel C27=matrix(umsexactive_count)

restore

preserve

collapse (count) measure1_count=measure1 measure2_count=measure2 measure3_count=measure3 measure4_count=measure4 ///
		 (mean) measure1_mean=measure1 measure2_mean=measure2 measure3_mean=measure3 measure4_mean=measure4 [pw=FQweight], ///
		 by(country umsexactive) 

foreach measure in `measure_list' {
	mean `measure'_mean if umsexactive==1
	matrix reference=r(table)
		matrix umsexactive_`measure'_percent=reference[1,1]*100
	egen umsexactive_`measure'_sd=sd(`measure'_mean) if umsexactive==1
	mean umsexactive_`measure'_sd
	matrix reference=r(table)
		matrix umsexactive_`measure'_sd=reference[1,1]*100
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel B27="Unmarried Sexually Active"
	putexcel D27=matrix(umsexactive_measure1_percent)
	putexcel E27=matrix(umsexactive_measure1_sd)
	putexcel F27=matrix(umsexactive_measure2_percent)
	putexcel G27=matrix(umsexactive_measure2_sd)
	putexcel H27=matrix(umsexactive_measure3_percent)
	putexcel I27=matrix(umsexactive_measure3_sd)
	putexcel J27=matrix(umsexactive_measure4_percent)
	putexcel K27=matrix(umsexactive_measure4_sd)
	
restore

preserve

collapse (count) u20_count=u20 if u20==1 [pw=FQweight], by(country)

mean u20_count
matrix reference=r(table)
	matrix u20_count=reference[1,1]
	
putexcel set "`excel'", modify sheet("Average")	

putexcel C28=matrix(u20_count)

restore

preserve

collapse (count) measure1_count=measure1 measure2_count=measure2 measure3_count=measure3 measure4_count=measure4 ///
		 (mean) measure1_mean=measure1 measure2_mean=measure2 measure3_mean=measure3 measure4_mean=measure4 [pw=FQweight], ///
		 by(country u20) 

foreach measure in `measure_list' {
	mean `measure'_mean if u20==1
	matrix reference=r(table)
		matrix u20_`measure'_percent=reference[1,1]*100
	egen u20_`measure'_sd=sd(`measure'_mean) if u20==1
	mean u20_`measure'_sd
	matrix reference=r(table)
		matrix u20_`measure'_sd=reference[1,1]*100
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel B28="Under 20"
	putexcel D28=matrix(u20_measure1_percent)
	putexcel E28=matrix(u20_measure1_sd)
	putexcel F28=matrix(u20_measure2_percent)
	putexcel G28=matrix(u20_measure2_sd)
	putexcel H28=matrix(u20_measure3_percent)
	putexcel I28=matrix(u20_measure3_sd)
	putexcel J28=matrix(u20_measure4_percent)
	putexcel K28=matrix(u20_measure4_sd)
	
restore

preserve

collapse (count) u25_count=u25 if u25==1 [pw=FQweight], by(country)

mean u25_count
matrix reference=r(table)
	matrix u25_count=reference[1,1]
	
putexcel set "`excel'", modify sheet("Average")	

putexcel C29=matrix(u25_count)

restore

preserve

collapse (count) measure1_count=measure1 measure2_count=measure2 measure3_count=measure3 measure4_count=measure4 ///
		 (mean) measure1_mean=measure1 measure2_mean=measure2 measure3_mean=measure3 measure4_mean=measure4 [pw=FQweight], ///
		 by(country u25) 

foreach measure in `measure_list' {
	mean `measure'_mean if u25==1
	matrix reference=r(table)
		matrix u25_`measure'_percent=reference[1,1]*100
	egen u25_`measure'_sd=sd(`measure'_mean) if u25==1
	mean u25_`measure'_sd
	matrix reference=r(table)
		matrix u25_`measure'_sd=reference[1,1]*100
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel B29="Under 25"
	putexcel D29=matrix(u25_measure1_percent)
	putexcel E29=matrix(u25_measure1_sd)
	putexcel F29=matrix(u25_measure2_percent)
	putexcel G29=matrix(u25_measure2_sd)
	putexcel H29=matrix(u25_measure3_percent)
	putexcel I29=matrix(u25_measure3_sd)
	putexcel J29=matrix(u25_measure4_percent)
	putexcel K29=matrix(u25_measure4_sd)
	
restore

	
*Appendix 5*
*******BY COUNTRY*******
preserve
collapse (mean) `measure_list' [pw=FQweight], by(country married) 
foreach measure in `measure_list' {
	keep if married==1
	gen `measure'_percent_mar=`measure'*100
	bysort country: gen `measure'_diff_measure1_mar=`measure'_percent-measure1_percent if married==1
	}
	
drop if married==0
drop `measure_list'
drop measure2_percent_mar measure3_percent_mar measure4_percent_mar
drop measure1_diff_measure1_mar

foreach country in `country_list' {

	putexcel set "`excel'", modify sheet("`country'")

	putexcel A31="Appendix 5"
		putexcel A32="Country"
		putexcel B32="Definition 1 (Actual)"
		putexcel C32="Definition 2"
		putexcel D32="Definition 3"
		putexcel E32="Definition 4"	
	putexcel A33="`country'"
		putexcel A34="Married"
		putexcel A35="Unmarried Sexually Active"
		putexcel A36="Under 20"
		putexcel A37="Under25"
	
	export excel measure1_percent measure2_diff_measure1_mar measure3_diff_measure1_mar measure4_diff_measure1_mar using "`excel'" if country=="`country'", sheet("`country'", modify) cell(B34)
	
	}		
restore
		
preserve
collapse (mean) `measure_list' [pw=FQweight], by(country umsexactive)
foreach measure in `measure_list' {
	keep if umsexactive==1
	gen `measure'_percent_umsa=`measure'*100
	bysort country: gen `measure'_diff_measure1_umsa=`measure'_percent-measure1_percent if umsexactive==1
	}
	
drop if umsexactive==0
drop `measure_list'
drop measure2_percent_umsa measure3_percent_umsa measure4_percent_umsa
drop measure1_diff_measure1_umsa

foreach country in `country_list' {
	
	export excel measure1_percent measure2_diff_measure1_umsa measure3_diff_measure1_umsa measure4_diff_measure1_umsa using "`excel'" if country=="`country'", sheet("`country'", modify) cell(B35)

	}
restore

preserve
collapse (mean) `measure_list' [pw=FQweight], by(country u20)
foreach measure in `measure_list' {
	keep if u20==1
	gen `measure'_percent_u20=`measure'*100
	bysort country: gen `measure'_diff_measure1_u20=`measure'_percent-measure1_percent if u20==1
	}
	
drop if u20==0
drop `measure_list'
drop measure2_percent_u20 measure3_percent_u20 measure4_percent_u20
drop measure1_diff_measure1_u20

foreach country in `country_list' {
	
	export excel measure1_percent measure2_diff_measure1_u20 measure3_diff_measure1_u20 measure4_diff_measure1_u20 using "`excel'" if country=="`country'", sheet("`country'", modify) cell(B36)

	}
restore

preserve
collapse (mean) `measure_list' [pw=FQweight], by(country u25)
foreach measure in `measure_list' {
	keep if u25==1
	gen `measure'_percent_u25=`measure'*100
	bysort country: gen `measure'_diff_measure1_u25=`measure'_percent-measure1_percent if u25==1
	}
	
drop if u25==0
drop `measure_list'
drop measure2_percent_u25 measure3_percent_u25 measure4_percent_u25
drop measure1_diff_measure1_u25

foreach country in `country_list' {
	
	export excel measure1_percent measure2_diff_measure1_u25 measure3_diff_measure1_u25 measure4_diff_measure1_u25 using "`excel'" if country=="`country'", sheet("`country'", modify) cell(B37)

	}
restore

*******AVERAGE*******
preserve

collapse (mean) `measure_list' [pw=FQweight], by(country married)

foreach measure in `measure_list' {
	keep if married==1
	gen `measure'_percent_married=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent_married-measure1_percent_married if married==1
	}
	
drop if married==0
drop `measure_list'
drop measure2_percent_married measure3_percent_married measure4_percent_married
drop measure1_diff_measure1

mean measure1
matrix reference=r(table)
	matrix measure1_mean_married=reference[1,1]
	
foreach n of numlist 2/4 {
	mean measure`n'_diff_measure1
	matrix reference=r(table)
		matrix measure`n'_diff_mean_married=reference[1,1]
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel A31="Appendix 5"
	putexcel B32="Definition 1 (Actual)"
	putexcel C32="Definition 2"
	putexcel D32="Definition 3"
	putexcel E32="Definition 4"
putexcel A33="Married"	
	putexcel B33=matrix(measure1_mean_married)
	putexcel C33=matrix(measure2_diff_mean_married)
	putexcel D33=matrix(measure3_diff_mean_married)
	putexcel E33=matrix(measure4_diff_mean_married)
	
restore

preserve

collapse (mean) `measure_list' [pw=FQweight], by(country umsexactive)

foreach measure in `measure_list' {
	keep if umsexactive==1
	gen `measure'_percent_umsexactive=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent_umsexactive-measure1_percent_umsexactive if umsexactive==1
	}
	
drop if umsexactive==0
drop `measure_list'
drop measure2_percent_umsexactive measure3_percent_umsexactive measure4_percent_umsexactive
drop measure1_diff_measure1

mean measure1
matrix reference=r(table)
	matrix measure1_mean_umsexactive=reference[1,1]
	
foreach n of numlist 2/4 {
	mean measure`n'_diff_measure1
	matrix reference=r(table)
		matrix measure`n'_diff_mean_umsexactive=reference[1,1]
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel A34="Unmarried Sexually Active"
	putexcel B34=matrix(measure1_mean_umsexactive)
	putexcel C34=matrix(measure2_diff_mean_umsexactive)
	putexcel D34=matrix(measure3_diff_mean_umsexactive)
	putexcel E34=matrix(measure4_diff_mean_umsexactive)
	
restore

preserve

collapse (mean) `measure_list' [pw=FQweight], by(country u20)

foreach measure in `measure_list' {
	keep if u20==1
	gen `measure'_percent_u20=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent_u20-measure1_percent_u20 if u20==1
	}
	
drop if u20==0
drop `measure_list'
drop measure2_percent_u20 measure3_percent_u20 measure4_percent_u20
drop measure1_diff_measure1

mean measure1
matrix reference=r(table)
	matrix measure1_mean_u20=reference[1,1]
	
foreach n of numlist 2/4 {
	mean measure`n'_diff_measure1
	matrix reference=r(table)
		matrix measure`n'_diff_mean_u20=reference[1,1]
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel A35="Under 20"
	putexcel B35=matrix(measure1_mean_u20)
	putexcel C35=matrix(measure2_diff_mean_u20)
	putexcel D35=matrix(measure3_diff_mean_u20)
	putexcel E35=matrix(measure4_diff_mean_u20)
	
restore

preserve

collapse (mean) `measure_list' [pw=FQweight], by(country u25)

foreach measure in `measure_list' {
	keep if u25==1
	gen `measure'_percent_u25=`measure'*100
	bysort country: gen `measure'_diff_measure1=`measure'_percent_u25-measure1_percent_u25 if u25==1
	}
	
drop if u25==0
drop `measure_list'
drop measure2_percent_u25 measure3_percent_u25 measure4_percent_u25
drop measure1_diff_measure1

mean measure1
matrix reference=r(table)
	matrix measure1_mean_u25=reference[1,1]
	
foreach n of numlist 2/4 {
	mean measure`n'_diff_measure1
	matrix reference=r(table)
		matrix measure`n'_diff_mean_u25=reference[1,1]
	}
	
putexcel set "`excel'", modify sheet("Average")

putexcel A36="Under 25"
	putexcel B36=matrix(measure1_mean_u25)
	putexcel C36=matrix(measure2_diff_mean_u25)
	putexcel D36=matrix(measure3_diff_mean_u25)
	putexcel E36=matrix(measure4_diff_mean_u25)
	
restore
*/
*Table 4*
foreach country in `country_list2' {
	foreach measure in `measure_list2' {
		svy: prop `measure' if country=="`country'", citype(wilson)
			matrix reference=r(table)
			matrix `country'_`measure'_percent=reference[1,2]*100
			matrix `country'_`measure'_ll=reference[5,2]*100
			matrix `country'_`measure'_ul=reference[6,2]*100
		}
	}
		
putexcel set "`excel'", modify sheet("Table 4")

putexcel C1="Definition 1"
	putexcel G1="Definition 2"
	putexcel H1="Definition 3"
	putexcel I1="Definition 4"
	putexcel J1="Definition 5"
putexcel A2="Country"
	putexcel B2="Subgroup"
	putexcel C2="Percent"
	putexcel E2="CI, LL"
	putexcel F2="CI, UL"
	putexcel G2="Percent"
	putexcel H2="Percent"
	putexcel I2="Percent"
	putexcel J2="Percent"
	putexcel L2="CI, LL"
	putexcel M2="CI, UL"
putexcel A3="Burkina Faso"
	putexcel B3="All"
		putexcel C3=matrix(BF_measure1_percent)
		putexcel E3=matrix(BF_measure1_ll)
		putexcel F3=matrix(BF_measure1_ul)
		putexcel G3=matrix(BF_measure2_percent)
		putexcel H3=matrix(BF_measure3_percent)
		putexcel I3=matrix(BF_measure4_percent)
		putexcel J3=matrix(BF_measure5_percent)
		putexcel L3=matrix(BF_measure5_ll)
		putexcel M3=matrix(BF_measure5_ul)
putexcel A8="Kenya"
	putexcel B8="All"
		putexcel C8=matrix(KE_measure1_percent)
		putexcel E8=matrix(KE_measure1_ll)
		putexcel F8=matrix(KE_measure1_ul)
		putexcel G8=matrix(KE_measure2_percent)
		putexcel H8=matrix(KE_measure3_percent)
		putexcel I8=matrix(KE_measure4_percent)
		putexcel J8=matrix(KE_measure5_percent)
		putexcel L8=matrix(KE_measure5_ll)
		putexcel M8=matrix(KE_measure5_ul)
putexcel A13="Uganda"
	putexcel B13="All"
		putexcel C13=matrix(UG_measure1_percent)
		putexcel E13=matrix(UG_measure1_ll)
		putexcel F13=matrix(UG_measure1_ul)
		putexcel G13=matrix(UG_measure2_percent)
		putexcel H13=matrix(UG_measure3_percent)
		putexcel I13=matrix(UG_measure4_percent)
		putexcel J13=matrix(UG_measure5_percent)
		putexcel L13=matrix(UG_measure5_ll)
		putexcel M13=matrix(UG_measure5_ul)
		
foreach country in `country_list2' {
	foreach subgroup in `subgroup_list' {
		foreach measure in `measure_list2' {
			svy:prop `measure' if country=="`country'" & `subgroup'==1, citype(wilson)
				matrix reference=r(table)
				matrix `country'_`subgroup'_`measure'_percent=reference[1,2]*100
				matrix `country'_`subgroup'_`measure'_ll=reference[5,2]*100
				matrix `country'_`subgroup'_`measure'_ul=reference[6,2]*100
			}
		}
	}
	
putexcel set "`excel'", modify sheet("Table 4")

putexcel B4="Married"
	putexcel C4=matrix(BF_married_measure1_percent)
	putexcel E4=matrix(BF_married_measure1_ll)
	putexcel F4=matrix(BF_married_measure1_ul)
	putexcel G4=matrix(BF_married_measure2_percent)
	putexcel H4=matrix(BF_married_measure3_percent)
	putexcel I4=matrix(BF_married_measure4_percent)
	putexcel J4=matrix(BF_married_measure5_percent)
	putexcel L4=matrix(BF_married_measure5_ll)
	putexcel M4=matrix(BF_married_measure5_ul)
putexcel B5="Unmarried Sexually Active"
	putexcel C5=matrix(BF_umsexactive_measure1_percent)
	putexcel E5=matrix(BF_umsexactive_measure1_ll)
	putexcel F5=matrix(BF_umsexactive_measure1_ul)
	putexcel G5=matrix(BF_umsexactive_measure2_percent)
	putexcel H5=matrix(BF_umsexactive_measure3_percent)
	putexcel I5=matrix(BF_umsexactive_measure4_percent)
	putexcel J5=matrix(BF_umsexactive_measure5_percent)
	putexcel L5=matrix(BF_umsexactive_measure5_ll)
	putexcel M5=matrix(BF_umsexactive_measure5_ul)
putexcel B6="Under 20"
	putexcel C6=matrix(BF_u20_measure1_percent)
	putexcel E6=matrix(BF_u20_measure1_ll)
	putexcel F6=matrix(BF_u20_measure1_ul)
	putexcel G6=matrix(BF_u20_measure2_percent)
	putexcel H6=matrix(BF_u20_measure3_percent)
	putexcel I6=matrix(BF_u20_measure4_percent)
	putexcel J6=matrix(BF_u20_measure5_percent)
	putexcel L6=matrix(BF_u20_measure5_ll)
	putexcel M6=matrix(BF_u20_measure5_ul)
putexcel B7="Under 25"
	putexcel C7=matrix(BF_u25_measure1_percent)
	putexcel E7=matrix(BF_u25_measure1_ll)
	putexcel F7=matrix(BF_u25_measure1_ul)
	putexcel G7=matrix(BF_u25_measure2_percent)
	putexcel H7=matrix(BF_u25_measure3_percent)
	putexcel I7=matrix(BF_u25_measure4_percent)
	putexcel J7=matrix(BF_u25_measure5_percent)
	putexcel L7=matrix(BF_u25_measure5_ll)
	putexcel M7=matrix(BF_u25_measure5_ul)	
putexcel B9="Married"
	putexcel C9=matrix(KE_married_measure1_percent)
	putexcel E9=matrix(KE_married_measure1_ll)
	putexcel F9=matrix(KE_married_measure1_ul)
	putexcel G9=matrix(KE_married_measure2_percent)
	putexcel H9=matrix(KE_married_measure3_percent)
	putexcel I9=matrix(KE_married_measure4_percent)
	putexcel J9=matrix(KE_married_measure5_percent)
	putexcel L9=matrix(KE_married_measure5_ll)
	putexcel M9=matrix(KE_married_measure5_ul)
putexcel B10="Unmarried Sexually Active"
	putexcel C10=matrix(KE_umsexactive_measure1_percent)
	putexcel E10=matrix(KE_umsexactive_measure1_ll)
	putexcel F10=matrix(KE_umsexactive_measure1_ul)
	putexcel G10=matrix(KE_umsexactive_measure2_percent)
	putexcel H10=matrix(KE_umsexactive_measure3_percent)
	putexcel I10=matrix(KE_umsexactive_measure4_percent)
	putexcel J10=matrix(KE_umsexactive_measure5_percent)
	putexcel L10=matrix(KE_umsexactive_measure5_ll)
	putexcel M10=matrix(KE_umsexactive_measure5_ul)
putexcel B11="Under 20"
	putexcel C11=matrix(KE_u20_measure1_percent)
	putexcel E11=matrix(KE_u20_measure1_ll)
	putexcel F11=matrix(KE_u20_measure1_ul)
	putexcel G11=matrix(KE_u20_measure2_percent)
	putexcel H11=matrix(KE_u20_measure3_percent)
	putexcel I11=matrix(KE_u20_measure4_percent)
	putexcel J11=matrix(KE_u20_measure5_percent)
	putexcel L11=matrix(KE_u20_measure5_ll)
	putexcel M11=matrix(KE_u20_measure5_ul)
putexcel B12="Under 25"
	putexcel C12=matrix(KE_u25_measure1_percent)
	putexcel E12=matrix(KE_u25_measure1_ll)
	putexcel F12=matrix(KE_u25_measure1_ul)
	putexcel G12=matrix(KE_u25_measure2_percent)
	putexcel H12=matrix(KE_u25_measure3_percent)
	putexcel I12=matrix(KE_u25_measure4_percent)
	putexcel J12=matrix(KE_u25_measure5_percent)
	putexcel L12=matrix(KE_u25_measure5_ll)
	putexcel M12=matrix(KE_u25_measure5_ul)
putexcel B14="Married"
	putexcel C14=matrix(UG_married_measure1_percent)
	putexcel E14=matrix(UG_married_measure1_ll)
	putexcel F14=matrix(UG_married_measure1_ul)
	putexcel G14=matrix(UG_married_measure2_percent)
	putexcel H14=matrix(UG_married_measure3_percent)
	putexcel I14=matrix(UG_married_measure4_percent)
	putexcel J14=matrix(UG_married_measure5_percent)
	putexcel L14=matrix(UG_married_measure5_ll)
	putexcel M14=matrix(UG_married_measure5_ul)
putexcel B15="Unmarried Sexually Active"
	putexcel C15=matrix(UG_umsexactive_measure1_percent)
	putexcel E15=matrix(UG_umsexactive_measure1_ll)
	putexcel F15=matrix(UG_umsexactive_measure1_ul)
	putexcel G15=matrix(UG_umsexactive_measure2_percent)
	putexcel H15=matrix(UG_umsexactive_measure3_percent)
	putexcel I15=matrix(UG_umsexactive_measure4_percent)
	putexcel J15=matrix(UG_umsexactive_measure5_percent)
	putexcel L15=matrix(UG_umsexactive_measure5_ll)
	putexcel M15=matrix(UG_umsexactive_measure5_ul)
putexcel B16="Under 20"
	putexcel C16=matrix(UG_u20_measure1_percent)
	putexcel E16=matrix(UG_u20_measure1_ll)
	putexcel F16=matrix(UG_u20_measure1_ul)
	putexcel G16=matrix(UG_u20_measure2_percent)
	putexcel H16=matrix(UG_u20_measure3_percent)
	putexcel I16=matrix(UG_u20_measure4_percent)
	putexcel J16=matrix(UG_u20_measure5_percent)
	putexcel L16=matrix(UG_u20_measure5_ll)
	putexcel M16=matrix(UG_u20_measure5_ul)
putexcel B17="Under 25"
	putexcel C17=matrix(UG_u25_measure1_percent)
	putexcel E17=matrix(UG_u25_measure1_ll)
	putexcel F17=matrix(UG_u25_measure1_ul)
	putexcel G17=matrix(UG_u25_measure2_percent)
	putexcel H17=matrix(UG_u25_measure3_percent)
	putexcel I17=matrix(UG_u25_measure4_percent)
	putexcel J17=matrix(UG_u25_measure5_percent)
	putexcel L17=matrix(UG_u25_measure5_ll)
	putexcel M17=matrix(UG_u25_measure5_ul)









	

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
global ECfolder "/Users/ealarson/Dropbox (Gates Institute)/1 DataManagement_General/X 9 EC use/EC_Analysis"


cd "$ECfolder"
log using "$ECfolder/log_files/PMA2020_ECMethodology_$date.log", replace

use "`datadir'/Nigeria_National/NG_NatR4.dta"
	pmasample
	keep country state round Cluster_ID strata FQmetainstanceID FQ_age school FQmarital_status last_time_sex last_time_sex_value age_at_first_sex current_user ///
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
	tostring Cluster_ID, replace
	rename Cluster_ID EA
	drop state
	save "`datadir'/EC/EC_v2.dta", replace

foreach dataset in ///
	"`datadir'/CoteDIvoire/CDR1.dta" ///
	"`datadir'/DRC_KC/DC_KCR6.dta" ///
	"`datadir'/DRC_Kinshasa/DC_KinR6.dta" ///
	"`datadir'/Ethiopia/ETR5.dta" ///
	"`datadir'/Ghana/GHR5.dta" ///
	"`datadir'/Niger_National/NE_NatR4.dta" ///
	"`datadir'/Rajasthan/INR2.dta" {
	preserve
		use `dataset'
		pmasample
		if country=="CD" {
			replace country="CD_CK" if province==2
			replace country="CD_Kinshasa" if province==1
			keep country round EA_ID FQmetainstanceID FQ_age school FQmarital_status last_time_sex last_time_sex_value age_at_first_sex current_user ///
				current_method current_methodnum* EC recent_user recent_method recent_methodnum* ///
				current_or_recent_user current_recent_method current_recent_methodnum  ///
				FQweight* cp mcp wealth* 
			}
		else {
			capture confirm EA
			if _rc!=. {
				keep country round EA_ID strata FQmetainstanceID FQ_age school FQmarital_status last_time_sex last_time_sex_value age_at_first_sex current_user ///
					current_method current_methodnum* EC recent_user recent_method recent_methodnum* ///
					current_or_recent_user current_recent_method current_recent_methodnum  ///
					FQweight* cp mcp wealth* 
				}
			else {
				keep country round EA strata FQmetainstanceID FQ_age school FQmarital_status last_time_sex last_time_sex_value age_at_first_sex current_user ///
					current_method current_methodnum* EC recent_user recent_method recent_methodnum* ///
					current_or_recent_user current_recent_method current_recent_methodnum  ///
					FQweight* cp mcp wealth* 
				}
			}
		tempfile dataset
		save `dataset', replace
	restore
	append using `dataset', force
	save, replace
	}
	
foreach dataset in ///
	"`datadir'/BurkinaFaso/BFR5.dta" ///
	"`datadir'/Kenya/KER6.dta" ///
	"`datadir'/Uganda/UGR6.dta" {
	preserve
		use `dataset'
		pmasample
		keep country round strata EA FQmetainstanceID FQ_age school FQmarital_status last_time_sex last_time_sex_value age_at_first_sex current_user ///
			current_method current_methodnum* EC recent_user recent_method recent_methodnum* ///
			current_or_recent_user current_recent_method current_recent_methodnum  ///
			FQweight* cp mcp wealth* emergency_12mo_yn
		if country=="BF" {
			tostring strata, replace
			replace strata="urban" if strata=="1"
			replace strata="rural" if strata=="2"
			local EA ea2
			gen `EA'=EA
			replace `EA'="7138" if `EA'=="10_N069d"
			replace `EA'="7758" if `EA'=="11_J049"
			replace `EA'="7663" if `EA'=="12_A004"
			replace `EA'="7540" if `EA'=="13_A001"
			replace `EA'="7761" if `EA'=="14_D020"
			replace `EA'="7625" if `EA'=="15_A004"
			replace `EA'="7157" if `EA'=="16_J049"
			replace `EA'="7578" if `EA'=="17_I043"
			replace `EA'="7553" if `EA'=="18_P079"
			replace `EA'="7397" if `EA'=="19_I050"
			replace `EA'="7252" if `EA'=="1_A005"
			replace `EA'="7356" if `EA'=="20_J045"
			replace `EA'="7261" if `EA'=="21_B007"
			replace `EA'="7061" if `EA'=="22_I044"
			replace `EA'="7144" if `EA'=="23_I045"
			replace `EA'="7102" if `EA'=="24_K052"
			replace `EA'="7034" if `EA'=="25_D019"
			replace `EA'="7564" if `EA'=="26_C010"
			replace `EA'="7877" if `EA'=="27_A001"
			replace `EA'="7408" if `EA'=="28_F027"
			replace `EA'="7159" if `EA'=="29_H036"
			replace `EA'="7766" if `EA'=="2_C016"
			replace `EA'="7636" if `EA'=="30_G037"
			replace `EA'="7967" if `EA'=="31_A005"
			replace `EA'="7067" if `EA'=="32_O075"
			replace `EA'="7148" if `EA'=="33_BB139"
			replace `EA'="7119" if `EA'=="34_E022"
			replace `EA'="7705" if `EA'=="35_M061"
			replace `EA'="7204" if `EA'=="36_L063"
			replace `EA'="7814" if `EA'=="37_B009"
			replace `EA'="7929" if `EA'=="38_A001"
			replace `EA'="7759" if `EA'=="39_B010"
			replace `EA'="7751" if `EA'=="3_E023"
			replace `EA'="7492" if `EA'=="40_B006"
			replace `EA'="7120" if `EA'=="41_C012"
			replace `EA'="7211" if `EA'=="42_B011"
			replace `EA'="7321" if `EA'=="43_G033"
			replace `EA'="7581" if `EA'=="44_C014"
			replace `EA'="7830" if `EA'=="45_D017"
			replace `EA'="7244" if `EA'=="46_C011"
			replace `EA'="7081" if `EA'=="47_A004"
			replace `EA'="7645" if `EA'=="48_L054"
			replace `EA'="7193" if `EA'=="49_P084"
			replace `EA'="7952" if `EA'=="4_M068"
			replace `EA'="7166" if `EA'=="50_S094"
			replace `EA'="7576" if `EA'=="51_D020"
			replace `EA'="7678" if `EA'=="52_D016"
			replace `EA'="7849" if `EA'=="53_B007"
			replace `EA'="7359" if `EA'=="5_D019"
			replace `EA'="7054" if `EA'=="6_M063"
			replace `EA'="7869" if `EA'=="7_C015"
			replace `EA'="7896" if `EA'=="8_D019"
			replace `EA'="7953" if `EA'=="9_A002"
			replace `EA'="7328" if `EA'=="10_A002"
			replace `EA'="7045" if `EA'=="11_N074"
			replace `EA'="7887" if `EA'=="15_B008"
			replace `EA'="7315" if `EA'=="17_D016"
			replace `EA'="7285" if `EA'=="21_B009"
			replace `EA'="7733" if `EA'=="22_C011"
			replace `EA'="7537" if `EA'=="28_H044"
			replace `EA'="7584" if `EA'=="32_E025"
			replace `EA'="7334" if `EA'=="37_A004"
			replace `EA'="7506" if `EA'=="38_B010"
			replace `EA'="7646" if `EA'=="39_B007"
			replace `EA'="7117" if `EA'=="3_B007"
			replace `EA'="7145" if `EA'=="41_A006"
			replace `EA'="7227" if `EA'=="42_BB10"
			replace `EA'="7124" if `EA'=="45_D018"
			replace `EA'="7029" if `EA'=="4_D016"
			replace `EA'="7262" if `EA'=="50_G032"
			replace `EA'="7857" if `EA'=="51_H037"
			replace `EA'="7793" if `EA'=="59_C011"
			replace `EA'="7925" if `EA'=="60_B008"
			replace `EA'="7514" if `EA'=="61_K051"
			replace `EA'="7420" if `EA'=="62_B008"
			replace `EA'="7098" if `EA'=="69_C013"
			replace `EA'="7961" if `EA'=="6_P076a"
			replace `EA'="7535" if `EA'=="71_M062b"
			replace `EA'="7721" if `EA'=="72_A004"
			replace `EA'="7582" if `EA'=="77_F028"
			replace `EA'="7071" if `EA'=="7_P084"
			replace `EA'="7862" if `EA'=="80_D015"
			replace `EA'="7583" if `EA'=="83_I049"
			replace `EA'="7521" if `EA'=="10_B011"
			replace `EA'="7082" if `EA'=="11_A004"
			replace `EA'="7380" if `EA'=="12_D022"
			replace `EA'="7323" if `EA'=="13_D020"
			replace `EA'="7491" if `EA'=="14_B006"
			replace `EA'="7605" if `EA'=="15_A001"
			replace `EA'="7142" if `EA'=="16_I045"
			replace `EA'="7279" if `EA'=="17_M062"
			replace `EA'="7370" if `EA'=="18_O072"
			replace `EA'="7725" if `EA'=="19_A003"
			replace `EA'="7212" if `EA'=="1_B006"
			replace `EA'="7811" if `EA'=="20_E026"
			replace `EA'="7859" if `EA'=="21_K054"
			replace `EA'="7472" if `EA'=="22_M063"
			replace `EA'="7175" if `EA'=="23_N071"
			replace `EA'="7234" if `EA'=="24_A005"
			replace `EA'="7799" if `EA'=="25_F027"
			replace `EA'="7909" if `EA'=="26_A005"
			replace `EA'="7650" if `EA'=="27_H039"
			replace `EA'="7271" if `EA'=="28_H036"
			replace `EA'="7779" if `EA'=="29_H039"
			replace `EA'="7016" if `EA'=="2_H039"
			replace `EA'="7447" if `EA'=="30_A006"
			replace `EA'="7708" if `EA'=="31_H045"
			replace `EA'="7880" if `EA'=="32_I047"
			replace `EA'="7116" if `EA'=="33_L065"
			replace `EA'="7431" if `EA'=="34_I043"
			replace `EA'="7048" if `EA'=="35_I044"
			replace `EA'="7006" if `EA'=="36_C014"
			replace `EA'="7339" if `EA'=="37_D020"
			replace `EA'="7003" if `EA'=="38_B008"
			replace `EA'="7610" if `EA'=="39_P085"
			replace `EA'="7185" if `EA'=="3_P076b"
			replace `EA'="7316" if `EA'=="40_I042"
			replace `EA'="7192" if `EA'=="41_B006"
			replace `EA'="7026" if `EA'=="42_B007"
			replace `EA'="7483" if `EA'=="43_G036"
			replace `EA'="7390" if `EA'=="44_B006"
			replace `EA'="7290" if `EA'=="45_G032"
			replace `EA'="7798" if `EA'=="46_F024"
			replace `EA'="7277" if `EA'=="47_C012"
			replace `EA'="7092" if `EA'=="48_C013"
			replace `EA'="7675" if `EA'=="49_F026"
			replace `EA'="7820" if `EA'=="4_C014"
			replace `EA'="7042" if `EA'=="50_G031"
			replace `EA'="7847" if `EA'=="51_J049"
			replace `EA'="7656" if `EA'=="52_L060"
			replace `EA'="7846" if `EA'=="53_BB138"
			replace `EA'="7243" if `EA'=="54_E023"
			replace `EA'="7009" if `EA'=="55_C012"
			replace `EA'="7369" if `EA'=="56_P076"
			replace `EA'="7516" if `EA'=="57_B007"
			replace `EA'="7891" if `EA'=="58_B009"
			replace `EA'="7111" if `EA'=="59_F032"
			replace `EA'="7139" if `EA'=="5_L063"
			replace `EA'="7554" if `EA'=="60_A003"
			replace `EA'="7934" if `EA'=="61_A004"
			replace `EA'="7879" if `EA'=="62_A004"
			replace `EA'="7056" if `EA'=="63_B008"
			replace `EA'="7791" if `EA'=="64_A005"
			replace `EA'="7373" if `EA'=="65_L064"
			replace `EA'="7296" if `EA'=="66_D017"
			replace `EA'="7955" if `EA'=="67_B010"
			replace `EA'="7774" if `EA'=="68_C013"
			replace `EA'="7400" if `EA'=="69_D019"
			replace `EA'="7602" if `EA'=="6_C013"
			replace `EA'="7358" if `EA'=="70_C013"
			replace `EA'="7621" if `EA'=="71_D016"
			replace `EA'="7620" if `EA'=="72_B008"
			replace `EA'="7336" if `EA'=="73_G031"
			replace `EA'="7332" if `EA'=="74_B007"
			replace `EA'="7104" if `EA'=="75_B006"
			replace `EA'="7206" if `EA'=="76_L055"
			replace `EA'="7734" if `EA'=="77_N075"
			replace `EA'="7407" if `EA'=="78_P086"
			replace `EA'="7750" if `EA'=="79_S093"
			replace `EA'="7156" if `EA'=="80_B009"
			replace `EA'="7422" if `EA'=="81_D017"
			replace `EA'="7972" if `EA'=="82_A002"
			replace `EA'="7412" if `EA'=="83_D017"
			replace `EA'="7335" if `EA'=="8_L061"
			replace `EA'="7813" if `EA'=="9_D016"
			destring `EA', generate(EA_ID)
			drop `EA'
			order EA_ID, after(EA)
			label var EA_ID "EA"
			}
		if country=="KE" {
			foreach EA in EA{
				replace `EA'="4169" if `EA'=="A3_SOKONI"
				replace `EA'="4092" if `EA'=="AKOM"
				replace `EA'="4707" if `EA'=="ARARONIK_A"
				replace `EA'="4446" if `EA'=="ASAYI_CENTRAL"
				replace `EA'="4626" if `EA'=="BAHATI_ANNEX"
				replace `EA'="4812" if `EA'=="BARANI_MIKINGI_LINI_A"
				replace `EA'="4592" if `EA'=="BELGUT"
				replace `EA'="4373" if `EA'=="BOMANI"
				replace `EA'="4740" if `EA'=="BOMORITA_ENSOKO"
				replace `EA'="4456" if `EA'=="BUKENGA"
				replace `EA'="4945" if `EA'=="BUKO"
				replace `EA'="4397" if `EA'=="BUKONOI"
				replace `EA'="4041" if `EA'=="BURUNDU_A"
				replace `EA'="4719" if `EA'=="BUYOFU"
				replace `EA'="4097" if `EA'=="BWALIRO"
				replace `EA'="4380" if `EA'=="CENTRAL__SOWETO"
				replace `EA'="4676" if `EA'=="CHEBOROR_WEST"
				replace `EA'="4485" if `EA'=="CHEMAGAL"
				replace `EA'="4408" if `EA'=="CHEMWOK_A"
				replace `EA'="4662" if `EA'=="CHEPARERIA_SOUTH"
				replace `EA'="4356" if `EA'=="CHEPKAIGAT_A_B"
				replace `EA'="4531" if `EA'=="CHEPTENDENIET"
				replace `EA'="4784" if `EA'=="CHESEBET"
				replace `EA'="4109" if `EA'=="DISTRICT_HOSPITAL_NYIGWA_E"
				replace `EA'="4502" if `EA'=="DONHOLM_B"
				replace `EA'="4687" if `EA'=="EISERO_AINAMOI"
				replace `EA'="4899" if `EA'=="EMAKALE_B"
				replace `EA'="4849" if `EA'=="EMOIN"
				replace `EA'="4969" if `EA'=="ESHIKANGU"
				replace `EA'="4318" if `EA'=="FORT_JESUS"
				replace `EA'="4000" if `EA'=="GACHOKA"
				replace `EA'="4480" if `EA'=="GICHAGI"
				replace `EA'="4919" if `EA'=="GIKIRA_A"
				replace `EA'="4211" if `EA'=="GITHUYA"
				replace `EA'="4495" if `EA'=="GREEN_FIELD_BLK_II"
				replace `EA'="4671" if `EA'=="GUEST"
				replace `EA'="4677" if `EA'=="HARAMBEE_A"
				replace `EA'="4682" if `EA'=="IBORIO_A"
				replace `EA'="4628" if `EA'=="KABINDEGE_NO_7"
				replace `EA'="4712" if `EA'=="KABIRO"
				replace `EA'="4439" if `EA'=="KABUNYERIA"
				replace `EA'="4878" if `EA'=="KADZANGANI"
				replace `EA'="4473" if `EA'=="KAHUHO"
				replace `EA'="4399" if `EA'=="KAIBOS_KAPLAIN"
				replace `EA'="4900" if `EA'=="KAKUUNI"
				replace `EA'="4882" if `EA'=="KALULINI"
				replace `EA'="4377" if `EA'=="KANGORA"
				replace `EA'="4711" if `EA'=="KAPARUSO_A"
				replace `EA'="4432" if `EA'=="KAPKERUGE_KAPTEBENGWO"
				replace `EA'="4990" if `EA'=="KAPOMUOTO"
				replace `EA'="4234" if `EA'=="KAPTELDON_A"
				replace `EA'="4760" if `EA'=="KAPTOROI"
				replace `EA'="4082" if `EA'=="KARINDI"
				replace `EA'="4967" if `EA'=="KASABUNI_OLD_A"
				replace `EA'="4203" if `EA'=="KASARANI"
				replace `EA'="4974" if `EA'=="KASES_KOSIA"
				replace `EA'="4130" if `EA'=="KASIONI"
				replace `EA'="4336" if `EA'=="KATILIKU"
				replace `EA'="4188" if `EA'=="KAWIDI_B"
				replace `EA'="4887" if `EA'=="KAYA"
				replace `EA'="4768" if `EA'=="KEDUKAK_CHERUNGUU"
				replace `EA'="4872" if `EA'=="KENYORO"
				replace `EA'="4361" if `EA'=="KENYORO_MOSOBETI_B"
				replace `EA'="4942" if `EA'=="KEWA"
				replace `EA'="4431" if `EA'=="KHAYO_B"
				replace `EA'="4738" if `EA'=="KIANDUTU_BLOCK_7"
				replace `EA'="4739" if `EA'=="KIANUMIRA_B"
				replace `EA'="4540" if `EA'=="KINOO_KAMUTHANGA"
				replace `EA'="4958" if `EA'=="KIONGONGI"
				replace `EA'="4047" if `EA'=="KIPTENDEN"
				replace `EA'="4950" if `EA'=="KIPTICHOR"
				replace `EA'="4212" if `EA'=="KIRAGU_B"
				replace `EA'="4994" if `EA'=="KIRANGI"
				replace `EA'="4165" if `EA'=="KIRIKO_SOUTH"
				replace `EA'="4694" if `EA'=="KITHUKINI_B"
				replace `EA'="4045" if `EA'=="KIVUVWANI"
				replace `EA'="4952" if `EA'=="KOIBEIYOT_SUGUTEK_EMIT"
				replace `EA'="4444" if `EA'=="KOSIRAI_KAPLAIN"
				replace `EA'="4021" if `EA'=="KWA_GOA"
				replace `EA'="4199" if `EA'=="KYANDA"
				replace `EA'="4605" if `EA'=="LANGATA_PHASE_1B"
				replace `EA'="4819" if `EA'=="LELA_A"
				replace `EA'="4366" if `EA'=="LIKHUMBI_A_SHILOLAVA"
				replace `EA'="4413" if `EA'=="LONDIAN_TOWN"
				replace `EA'="4260" if `EA'=="LUKHUNA"
				replace `EA'="4655" if `EA'=="LUTASO"
				replace `EA'="4378" if `EA'=="MACHENGO"
				replace `EA'="4036" if `EA'=="MAGARE_A"
				replace `EA'="4159" if `EA'=="MAHWI"
				replace `EA'="4353" if `EA'=="MAJENGO_MAPYA_A"
				replace `EA'="4895" if `EA'=="MAKINANGOMBE"
				replace `EA'="4985" if `EA'=="MAKULULU"
				replace `EA'="4795" if `EA'=="MALINDA_A"
				replace `EA'="4956" if `EA'=="MAOSI_A"
				replace `EA'="4207" if `EA'=="MATENDE_A"
				replace `EA'="4110" if `EA'=="MATIMBENI"
				replace `EA'="4879" if `EA'=="MBARAKANI_B"
				replace `EA'="4656" if `EA'=="MEGUTI_B"
				replace `EA'="4259" if `EA'=="MIDOINA_KADZIWENI"
				replace `EA'="4885" if `EA'=="MILIMANI"
				replace `EA'="4224" if `EA'=="MKULIMA"
				replace `EA'="4674" if `EA'=="MOGOLE"
				replace `EA'="4907" if `EA'=="MORKORIO"
				replace `EA'="4481" if `EA'=="MOSQUITO"
				replace `EA'="4292" if `EA'=="MUKUTHU"
				replace `EA'="4684" if `EA'=="MURMOT"
				replace `EA'="4948" if `EA'=="MURUNY"
				replace `EA'="4533" if `EA'=="MUTHAIGA_44"
				replace `EA'="4392" if `EA'=="MWANAMKIA_A"
				replace `EA'="4965" if `EA'=="MWIKONGO"
				replace `EA'="4745" if `EA'=="NAMBWANI_B"
				replace `EA'="4921" if `EA'=="NAMILAMA"
				replace `EA'="4873" if `EA'=="NGAIRWE_C"
				replace `EA'="4701" if `EA'=="NGEANI"
				replace `EA'="4710" if `EA'=="NGEI_2_A"
				replace `EA'="4603" if `EA'=="NGENYBOGURIO_A"
				replace `EA'="4566" if `EA'=="NGINA_A"
				replace `EA'="4926" if `EA'=="NGULUNGU"
				replace `EA'="4800" if `EA'=="NYALENYA_DADRA"
				replace `EA'="4639" if `EA'=="NYAMIOBO_MOKORONGOSI"
				replace `EA'="4586" if `EA'=="NYANGURU_II_A"
				replace `EA'="4871" if `EA'=="OMARI_MBOGA_A"
				replace `EA'="4486" if `EA'=="ONYATTA_D"
				replace `EA'="4529" if `EA'=="PANGANI_A_1"
				replace `EA'="4723" if `EA'=="RIAMAYOGE"
				replace `EA'="4766" if `EA'=="RURII"
				replace `EA'="4943" if `EA'=="SAKA_B_i"
				replace `EA'="4523" if `EA'=="SAKWA_A"
				replace `EA'="4214" if `EA'=="SARAMEK_FOREST"
				replace `EA'="4608" if `EA'=="SARMACH"
				replace `EA'="4549" if `EA'=="SCHEME_LINE"
				replace `EA'="4410" if `EA'=="SECTOR_3_A"
				replace `EA'="4163" if `EA'=="SHISELE"
				replace `EA'="4665" if `EA'=="SHIVIKHWA_B"
				replace `EA'="4938" if `EA'=="SIGILAI"
				replace `EA'="4963" if `EA'=="SIMOTWET"
				replace `EA'="4905" if `EA'=="SIRONGO"
				replace `EA'="4843" if `EA'=="SYOYUA"
				replace `EA'="4329" if `EA'=="THAARA_A"
				replace `EA'="4499" if `EA'=="TIGORY_A"
				replace `EA'="4757" if `EA'=="TINGARE"
				replace `EA'="4245" if `EA'=="TOMBOIYOT"
				replace `EA'="4013" if `EA'=="TUDOKUMOL"
				replace `EA'="4666" if `EA'=="UGUNJA_5"
				replace `EA'="4351" if `EA'=="ULOMA"
				replace `EA'="4691" if `EA'=="UPPER_ECHINJIA"
				replace `EA'="4534" if `EA'=="UTAWALA_B"
				replace `EA'="4286" if `EA'=="VANGANYAWA"
				replace `EA'="4838" if `EA'=="WHITE_HOUSE"
				replace `EA'="4230" if `EA'=="YAKILINDI"
				replace `EA'="4578" if `EA'=="ZONE_48"
				}
			destring EA, generate(EA_ID)
			order EA_ID, after(EA)
			drop EA
			}
		if country=="UG" {
			replace EA="3453" if EA=="abyongdyang_c"
			replace EA="3866" if EA=="acutanena_b"
			replace EA="3757" if EA=="agonyo_i_a"
			replace EA="3224" if EA=="agoro_central_a"
			replace EA="3627" if EA=="akwera"
			replace EA="3300" if EA=="aloi"
			replace EA="3292" if EA=="apotkitoo_b"
			replace EA="3167" if EA=="ariabo"
			replace EA="3635" if EA=="baronger"
			replace EA="3108" if EA=="buchiwedo_a"
			replace EA="3045" if EA=="bugalo"
			replace EA="3415" if EA=="bugambira_a"
			replace EA="3978" if EA=="bugonga_e"
			replace EA="3099" if EA=="bugorora"
			replace EA="3382" if EA=="bukasa_a"
			replace EA="3813" if EA=="bulange_central_a"
			replace EA="3714" if EA=="bulegeya_kinataka_lc_a"
			replace EA="3674" if EA=="bumusomi_ii_a"
			replace EA="3381" if EA=="busamu_camp_c"
			replace EA="3376" if EA=="busegula_naisembe_a"
			replace EA="3061" if EA=="butaserwa_a"
			replace EA="3042" if EA=="bwera_a"
			replace EA="3069" if EA=="central_c_h"
			replace EA="3585" if EA=="coo_rom"
			replace EA="3474" if EA=="coopil_b"
			replace EA="3057" if EA=="dasa"
			replace EA="3811" if EA=="go_down_ii_b"
			replace EA="3393" if EA=="good_hope_zone_d"
			replace EA="3015" if EA=="gwetom_a"
			replace EA="3390" if EA=="kagandu_a"
			replace EA="3707" if EA=="kajiriwar"
			replace EA="3404" if EA=="kakiika_i"
			replace EA="3505" if EA=="kakooge_lc_1_a"
			replace EA="3040" if EA=="kakunyumunyu_b"
			replace EA="3959" if EA=="kamacha_a"
			replace EA="3466" if EA=="kamoru_south_a"
			replace EA="3966" if EA=="kamurara_ii"
			replace EA="3073" if EA=="kanyale"
			replace EA="3831" if EA=="kasejere"
			replace EA="3252" if EA=="kawaala_i_zone_j"
			replace EA="3324" if EA=="kayunga"
			replace EA="3184" if EA=="kemihoko"
			replace EA="3812" if EA=="kibingo"
			replace EA="3941" if EA=="kifuruta_ii_a"
			replace EA="3669" if EA=="kigugo"
			replace EA="3245" if EA=="kikoto"
			replace EA="3140" if EA=="kimigi_b"
			replace EA="3515" if EA=="kinawataka_e"
			replace EA="3905" if EA=="kirombe_b_c"
			replace EA="3897" if EA=="kiryangobe_a"
			replace EA="3023" if EA=="kisenyi_ii_i"
			replace EA="3874" if EA=="kitagata_trc"
			replace EA="3853" if EA=="kitambogo_b"
			replace EA="3506" if EA=="kitega_c"
			replace EA="3645" if EA=="kiyanja_a"
			replace EA="3655" if EA=="kooki_d_h"
			replace EA="3428" if EA=="kotiokot_a"
			replace EA="3086" if EA=="kwata_b"
			replace EA="3863" if EA=="kyamusimba"
			replace EA="3315" if EA=="kyarugamba"
			replace EA="3926" if EA=="lokwakais_a"
			replace EA="3403" if EA=="lomachariwaret_a"
			replace EA="3705" if EA=="loreng_a"
			replace EA="3018" if EA=="lufudu_a"
			replace EA="3531" if EA=="lufula_a"
			replace EA="3323" if EA=="lwanika_b_lc1_b"
			replace EA="3639" if EA=="makindye_division_central_a"
			replace EA="3610" if EA=="mbogo_g"
			replace EA="3858" if EA=="mirimu_c"
			replace EA="3653" if EA=="moru_a"
			replace EA="3839" if EA=="mpanga_mushanju"
			replace EA="3437" if EA=="mpangati_b"
			replace EA="3651" if EA=="mugoma_a"
			replace EA="3176" if EA=="mugongo_a_lc_1_k"
			replace EA="3702" if EA=="mugowa_zone_d"
			replace EA="3732" if EA=="muliki"
			replace EA="3559" if EA=="mulima"
			replace EA="3239" if EA=="mushembe"
			replace EA="3784" if EA=="nachua"
			replace EA="3540" if EA=="nakibizzi_c"
			replace EA="3640" if EA=="nakiyanja_d"
			replace EA="3233" if EA=="namayemba_b_lc_1_a"
			replace EA="3756" if EA=="namazaba"
			replace EA="3137" if EA=="namungalwe_rural_a"
			replace EA="3931" if EA=="namunyumya_a_a"
			replace EA="3925" if EA=="napetaoi"
			replace EA="3511" if EA=="nkandwa_a_a"
			replace EA="3794" if EA=="nkere_a"
			replace EA="3909" if EA=="nkyamani"
			replace EA="3522" if EA=="nyakatooke_ii"
			replace EA="3728" if EA=="oparomo"
			replace EA="3668" if EA=="opungo_a"
			replace EA="3053" if EA=="osau"
			replace EA="3686" if EA=="otumpili_north"
			replace EA="3211" if EA=="pengabe_society"
			replace EA="3717" if EA=="robuyi_a"
			replace EA="3731" if EA=="rubumba"
			replace EA="3735" if EA=="ruyonza_i"
			replace EA="3203" if EA=="rwaburegyeya_a"
			replace EA="3436" if EA=="rwekubo"
			replace EA="3041" if EA=="rwengoma_b_iii"
			replace EA="3507" if EA=="shikhuyu_b"
			replace EA="3421" if EA=="sinyani_c"
			replace EA="3210" if EA=="siriba_c"
			replace EA="3826" if EA=="siwa_b_a"
			replace EA="3281" if EA=="tangiriza"
			replace EA="3974" if EA=="upper_mawanga_zone_c"
			replace EA="3973" if EA=="zone_4_c"
			replace EA="3056" if EA=="zone_8_t"
			replace EA="3246" if EA=="zone_vi_b"
			* new in R6
			replace EA="3896" if EA=="kokeris"
			destring EA, generate(EA_ID)
			order EA_ID, after(EA)
			label var EA_ID "EA ID (random)"
			drop EA
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

drop FQweightorig
egen one=tag(FQmetainstanceID)
drop FQmetainstanceID
tostring EA_ID, replace
replace EA=EA_ID if EA==""
drop EA_ID
replace country="CdI" if country=="Cote D'Ivoire"
	
save "`datadir'/ECdata_v2.dta", replace
		

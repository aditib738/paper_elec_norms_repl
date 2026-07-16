/* bring ihds panel data */
use $tmp/ihds_panel, clear

/* merge with treatment id */
/* merge with district treatment data */
decode stateid, gen(pc11_state_name)
replace district = distname if mi(district)
decode district, gen(pc11_district_name)

/* clean further */
name_clean pc11_state_name, replace
replace pc11_state_name = subinstr(pc11_state_name, "+", " ", .)
split pc11_state_name, p(-)
drop pc11_state_name pc11_state_name2
ren pc11_state_name1 pc11_state_name
name_clean pc11_district_name, replace

/* harmonize state names */
replace pc11_state_name = "odisha" if pc11_state_name == "orissa"
replace pc11_state_name = "chhattisgarh" if pc11_state_name == "chhatishgarh"
replace pc11_state_name = "gujarat" if pc11_state_name == "gujarat twenty four"
replace pc11_state_name = "uttarakhand" if pc11_state_name == "uttaranchal"
replace pc11_state_name = "puducherry" if pc11_state_name == "pondicherry"

/* harmonize district names */
replace pc11_district_name = "farrukhabad" if pc11_district_name == "farrukabad"
replace pc11_district_name = "mahamaya nagar" if pc11_district_name == "hathras"
replace pc11_district_name = "jyotiba phule nagar" if pc11_district_name == "jyotiva phule nagar"
replace pc11_district_name = "sant ravidas nagar bhadohi" if pc11_district_name == "sant ravidas nagar"
replace pc11_district_name = "shrawasti" if pc11_district_name == "sharawasti"
replace pc11_district_name = "bilaspur" if pc11_district_name == "bilas pur"
replace pc11_district_name = "janjgir champa" if pc11_district_name == "janjgir"
replace pc11_district_name = "uttar bastar kanker" if pc11_district_name == "kanker"
replace pc11_district_name = "kabeerdham" if pc11_district_name == "kawardha"
replace pc11_district_name = "bilaspur" if pc11_district_name == "korba"
replace pc11_district_name = "surguja" if pc11_district_name == "sarguja"
replace pc11_district_name = subinstr(pc11_district_name, " pur", "pur", .)
replace pc11_district_name = "dakshina kannada" if pc11_district_name == "dakshin kannada"
replace pc11_district_name = "uttara kannada" if pc11_district_name == "uttar kannad"
replace pc11_district_name = "amravati" if pc11_district_name == "amarawti"
replace pc11_district_name = "nashik" if pc11_district_name == "nasik"
replace pc11_district_name = "fatehgarh sahib" if pc11_district_name == "fatehgarh"
replace pc11_district_name = "shahid bhagat singh nagar" if pc11_district_name == "nawanshahr"
replace pc11_district_name = "dharmapuri" if pc11_district_name == "dharampuri"
replace pc11_district_name = "tiruchirappalli" if pc11_district_name == "tiruchchirappalli"
replace pc11_district_name = "ahmadabad" if pc11_district_name == "ahmedabad"
replace pc11_district_name = "ysr kadapa" if pc11_district_name == "cuddapah"
replace pc11_district_name = "hisar" if pc11_district_name == "hissar"
replace pc11_district_name = "jalpaiguri" if pc11_district_name == "jalapiguri"
replace pc11_district_name = "jhunjhunun" if pc11_district_name == "jhunjhunu"
replace pc11_district_name = "daman" if pc11_district_name == "daman diu"
replace pc11_district_name = "pashchim champaran" if pc11_district_name == "paschimi champaran"
replace pc11_district_name = "purba champaran" if pc11_district_name == "purbi champaran"
replace pc11_district_name = "puducherry" if pc11_district_name == "pondicherry"
replace pc11_district_name = "siddharthnagar" if pc11_district_name == "siddharathnagar"
replace pc11_district_name = "pashchimi singhbhum" if pc11_district_name == "pashchimi singbhum"
replace pc11_district_name = "morigaon" if pc11_district_name == "marigaon"
replace pc11_district_name = "rajouri" if pc11_district_name == "rajauri"
replace pc11_district_name = "subarnapur" if pc11_district_name == "sonapur"

/* merge */
merge m:1 pc11_state_name pc11_district_name using $tmp/districts_treat, keep(match) nogen

/* define treatment */
gen treat = 1 if inlist(type, 10, 12)
replace treat = 0 if type == 11
replace treat = 0 if type == 99

/* dummy for post 2005 */
gen post = year == 2012

/* generate treat X post */
gen treat_post = treat * post

/* hhid */
egen hid = group(stateid distid psuid hhid hhsplitid)

/* generate outcomes of interest */
gen flfp_biz = wkbusiness if year == 2005
replace flfp_biz = 1 if inlist(wkbusiness, 3, 4) & year == 2012
replace flfp_biz = 0 if mi(flfp_biz)

gen flfp_sal = wksalary if year == 2005
replace flfp_sal = 1 if inlist(wksalary, 3, 4) & year == 2012
replace flfp_sal = 0 if mi(flfp_sal)

/* generate interactions */
gen treat_post_uc = treat_post*uc
gen treat_post_scst = treat_post*scst
gen tp = treat_post

/* generate district fixed effect */
egen pd = group(pc11_state_id pc11_district_id )

/* run regression */
set scheme tab2
estimates clear
reghdfe flfp treat_post [pw = sweight], absorb(hid year) cluster(pd)
estimates store m1
reghdfe flfp tp  uc treat_post_uc [pw = sweight], absorb(hid year) cluster(pd)
estimates store m2
reghdfe flfp tp scst treat_post_scst [pw = sweight], absorb(hid year) cluster(pd)
estimates store m3

reghdfe flfp_biz treat_post [pw = sweight], absorb(hid year) cluster(pd)
estimates store b1
reghdfe flfp_biz uc tp treat_post_uc [pw = sweight], absorb(hid year) cluster(pd)
estimates store b2
reghdfe flfp_biz scst tp treat_post_scst [pw = sweight], absorb(hid year) cluster(pd)
estimates store b3

/* create nice coef plots */
coefplot m1 m2 m3, keep(treat_post treat_post_uc treat_post_scst) yline(0) levels(90) vertical ///
legend(order(2 "Aggregate effect" 4 "Interaction: Upper caste" 6 "Interaction: SC/ST")  size(medsmall)) ///
msize(large) xlabel(, labsize(medsmall)) ylabel(, labsize(medsmall)) ///
name(first, replace) title(Outcome: FLFP)
graph export $out/flfp_ihds.png, replace

coefplot b1 b2 b3, keep(treat_post treat_post_uc treat_post_scst) yline(0) levels(90) vertical ///
legend(order(2 "Aggregate effect" 4 "Interaction: Upper caste" 6 "Interaction: SC/ST")  size(medsmall)) ///
msize(large) xlabel(, labsize(medsmall)) ylabel(, labsize(medsmall)) ///
name (second, replace) title(Outcome: FLFP business)
graph export $out/flfp_biz_ihds.png, replace


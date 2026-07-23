/* import data */
use $tmp/ihds_dist_analysis, clear

/* keep only unique obs */
duplicates tag pc11_state_id pc11_district_id period, gen(tag)
keep if tag == 0
drop tag

/* merge consumption per capita */
merge 1:m pc11_state_id pc11_district_id period using $tmp/elec_analysis, keep(match) nogen

/* generate variable for treat_post */
gen treat_post = treat * post

/* generate linear time trends */
egen district = group(pc11_state_id pc11_district_id)
egen state_trend = group(pc11_state_id period)
egen dec_trend = group(dec period)
egen quart_trend = group(quart period)
drop if mi(dec)

/* drop UTs */
drop if inlist(pc11_state_name, "chandigarh", "andaman nicobar islands", ///
 "dadra nagar haveli", "daman diu", "goa", "lakshadweep", "puducherry")

/* drop pre treatment period */
drop if period == 0

/* create population */
gen pop = pc_tot_p if period == 1
replace pop = 0 if mi(pop)
sort shrid2 pop
drop pc_tot_p
bys shrid2: egen pc_tot_p = max(pop)
drop pop


/********************************************************/
/* Generate caste composition and relevant interactions */
/********************************************************/

gen scst_05 = scst if period == 1
replace scst_05 = 0 if mi(scst_05)
drop scst
bys shrid2: egen scst = max(scst_05)

/* gen interactions */
gen scst_post = scst * post
gen elec_scst = treat_post * scst

gen uc_05 = group1 + group2 if period == 1
replace uc_05 = 0 if mi(uc_05)
drop uc
bys shrid2: egen uc = max(uc_05)

/* gen interactions */
gen uc_post = uc * post
gen elec_uc = treat_post * uc

/* level outcomes */
foreach g in f m {
gen ln_non_ag_`g' = ln(ec_emp_`g' + 1)
gen ln_non_ag_hh_`g' = ln(pc_main_hh_`g' + 1)
gen ln_non_ag_ot_`g' = ln(pc_main_ot_`g' + 1)

gen own_`g' = ec13_count_own_`g' if period == 2
replace own_`g' = ec05_count_own_`g' if period == 1
replace own_`g' = ec98_count_own_`g' if period == 0
gen any_own_`g' = own_`g' > 0  & !mi(own_`g')
gen ln_own_`g' = ln(own_`g' + 1)
}


/*********/
/* SC/ST */
/*********/


reghdfe ln_non_ag_f treat_post scst scst_post elec_scst pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe ln_non_ag_m treat_post scst scst_post elec_scst pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe ln_non_ag_hh_f treat_post scst scst_post elec_scst pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_hh_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe ln_non_ag_hh_m treat_post scst scst_post elec_scst pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_hh_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe ln_non_ag_ot_f treat_post scst scst_post elec_scst pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_ot_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ln_non_ag_ot_m treat_post scst scst_post elec_scst pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_ot_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe any_own_f treat_post scst scst_post elec_scst pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum any_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe any_own_m treat_post scst scst_post elec_scst pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum any_own_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m6 m7 m8 using ///
$out/flfp_scst_villag_levels.csv, keep(treat_post elec_scst) ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
scst "SC-ST share" scst_post "SC-ST share x 1[2011]" ///
elec_scst "SC-ST share x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace


/******/
/* UC */
/******/


reghdfe ln_non_ag_f treat_post uc uc_post elec_uc pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe ln_non_ag_m treat_post uc uc_post elec_uc pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe ln_non_ag_hh_f treat_post uc uc_post elec_uc pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_hh_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe ln_non_ag_hh_m treat_post uc uc_post elec_uc pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_hh_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe ln_non_ag_ot_f treat_post uc uc_post elec_uc pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_ot_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ln_non_ag_ot_m treat_post uc uc_post elec_uc pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_non_ag_ot_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe any_own_f treat_post uc uc_post elec_uc pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum any_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe any_own_m treat_post uc uc_post elec_uc pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum any_own_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m6 m7 m8 using ///
$out/flfp_uc_villag_levels.csv, keep(treat_post elec_uc) ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
uc "UC share" uc_post "UC share x 1[2011]" ///
elec_uc "UC share x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

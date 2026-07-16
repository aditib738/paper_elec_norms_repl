/* controls fe interacted version of caste table */
/* import data */
/* replicate purdah analysis at village level */
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

/* merge with covars */
ren shrid1 shrid
merge m:1 shrid using ~/data/covars, keep(match) nogen

/* create interactions */
ren pc01_vd_* *
global covars t_p m_sch s_sch s_s_sch college hosp tot_exp tot_irr tar_road dist_town
foreach var of var $covars {
gen post_`var' = post * `var'
}

global covar_trends post_*


/*********/
/* SC/ST */
/*********/


reghdfe pc_mainwork_fshare treat_post $covar_trends scst scst_post elec_scst [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe pc_main_al_fshare treat_post $covar_trends scst scst_post elec_scst [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe pc_main_cl_fshare treat_post $covar_trends scst scst_post elec_scst [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe pc_main_ot_fshare treat_post $covar_trends scst scst_post elec_scst [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe pc_main_hh_fshare treat_post $covar_trends scst scst_post elec_scst [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ec_share_count_own_f treat_post $covar_trends scst scst_post elec_scst [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe ec_share_count_f treat_post $covar_trends scst scst_post elec_scst [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe ec_share_emp_f treat_post $covar_trends scst scst_post elec_scst [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/controls_int/flfp_scst_village_c.csv, keep(elec_scst) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
scst "SC-ST share" scst_post "SC-ST share x 1[2011]" ///
elec_scst "SC-ST share x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

/******/
/* UC */
/******/


reghdfe pc_mainwork_fshare treat_post $covar_trends uc uc_post elec_uc [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe pc_main_al_fshare treat_post $covar_trends uc uc_post elec_uc [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe pc_main_cl_fshare treat_post $covar_trends uc uc_post elec_uc [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe pc_main_ot_fshare treat_post $covar_trends uc uc_post elec_uc [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe pc_main_hh_fshare treat_post $covar_trends uc uc_post elec_uc [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ec_share_count_own_f treat_post $covar_trends uc uc_post elec_uc [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe ec_share_count_f treat_post $covar_trends uc uc_post elec_uc [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe ec_share_emp_f treat_post $covar_trends uc uc_post elec_uc [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/controls_int/flfp_uc_village_c.csv, keep(elec_uc) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
uc "UC share" uc_post "UC share x 1[2011]" ///
elec_uc "UC share x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace
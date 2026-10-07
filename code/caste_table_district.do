/* this do file replicates the caste heterogeneity analysis at the district level */
/* prep caste data */
use $tmp/ihds_dist_analysis, clear

/* keep only unique obs */
duplicates tag pc11_state_id pc11_district_id period, gen(tag)
keep if tag == 0
drop tag

/* merge consumption per capita */
merge 1:m pc11_state_id pc11_district_id period using $tmp/main_analysis, keep(match) nogen

global covar_trends pre_* post_*

/* get number of firms */
gen firms = ec13_count_all if period == 2
replace firms = ec05_count_all if period == 1
replace firms = ec98_count_all if period == 0

gen ec_firm_f = ec13_count_f if period == 2
replace ec_firm_f = ec05_count_f if period == 1
replace ec_firm_f = ec98_count_f if period == 0

gen ec_own_f = ec13_count_own_f if period == 2
replace ec_own_f = ec05_count_own_f if period == 1
replace ec_own_f = ec98_count_own_f if period == 0

/* Generate caste composition and relevant interactions */
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

/* collapse */
collapse_save_labels
collapse (sum) pc_mainwork_f pc_main_al_f pc_main_cl_f pc_main_hh_f pc_main_ot_f pc_mainwork_p ec_emp_f ec_emp_all ///
pc_main_al_m pc_main_cl_m pc_main_ot_m pc_main_hh_m ec_emp_m ///
firms ec_firm_f ec_own_f pc_tot_p (firstnm) pc11_state_id pc11_district_id scst uc uc_post elec_uc scst_post elec_scst ///
treat post treat_post pre treat_pre (mean) secc_cons_pc_rural ///
$covar_trends, by(district period)
collapse_apply_labels

/* create quartiles of districts within states by exp per capita */
egen quart = xtile(secc_cons_pc_rural), n(4) by(pc11_state_id)

/* create deciles of districts by exp per capita */
xtile dec = secc_cons_pc_rural, nq(10)

/* state * year */
egen temp = group(pc11_state_id)
gen state_year = string(temp) + "-" + string(period)
drop temp
replace state_year = subinstr(state_year, "-", "", .)
destring state_year, replace

/* recreate main outcomes at district level */
gen pc_mainwork_fshare = pc_mainwork_f/pc_mainwork_p
gen pc_main_al_fshare = pc_main_al_f/(pc_main_al_f + pc_main_al_m)
gen pc_main_cl_fshare = pc_main_cl_f/(pc_main_cl_f + pc_main_cl_m) 
gen pc_main_ot_fshare = pc_main_ot_f/(pc_main_ot_f + pc_main_ot_m)
gen pc_main_hh_fshare = pc_main_hh_f/(pc_main_hh_f + pc_main_hh_m) 
gen ec_share_count_own_f = ec_own_f/firms
gen ec_share_count_f = ec_firm_f/firms
gen ec_share_emp_f = ec_emp_f/(ec_emp_f + ec_emp_m)

/* generate linear time trends */
egen state_trend = group(pc11_state_id period)
egen dec_trend = group(dec period)
egen quart_trend = group(quart period)

cap log close
log using $out/district_caste.txt, text replace 

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

log close
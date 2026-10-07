/* this do file runs the main analysis at district level */
use $tmp/main_analysis, clear

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


/* collapse */
collapse_save_labels
collapse (sum) pc_mainwork_f pc_main_al_f pc_main_cl_f pc_main_hh_f pc_main_ot_f pc_mainwork_p ec_emp_f ec_emp_all ///
pc_main_al_m pc_main_cl_m pc_main_ot_m pc_main_hh_m ec_emp_m ///
firms ec_firm_f ec_own_f pc_tot_p (firstnm) pc11_state_id treat post treat_post pre treat_pre (mean) secc_cons_pc_rural ///
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
log using $out/district_main.txt, text replace 

/* main regressions */
/* A. pc_mainwork_fshare */
reghdfe pc_mainwork_fshare treat_pre treat_post $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* B. pc_main_al_fshare */
reghdfe pc_main_al_fshare treat_pre treat_post  $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* C. pc_main_cl_fshare */
reghdfe pc_main_cl_fshare treat_pre treat_post  $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

/* D. pc_main_ot_fshare */
reghdfe pc_main_ot_fshare treat_pre treat_post $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

/* E. pc_main_hh_fshare */
reghdfe pc_main_hh_fshare treat_pre treat_post $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

/* F. ec_share_count_own_f */
reghdfe ec_share_count_own_f treat_pre treat_post $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

/* G. ec_share_count_f */
reghdfe ec_share_count_f treat_pre treat_post $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

/* H. ec_share_emp_f */
reghdfe ec_share_emp_f treat_pre treat_post $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

log close 
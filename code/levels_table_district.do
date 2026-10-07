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
pc_main_al_m pc_main_cl_m pc_main_ot_m pc_main_hh_m ec_emp_m pc_m pc_f ///
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
/* number of female ag employees */
gen pc_emp_fag = pc_main_cl_f + pc_main_al_f

/* number of male ag employees */
gen emp_ag = pc_main_cl_m + pc_main_al_m

/* generate logs */
gen ln_men = ln(ec_emp_m + 1)
gen ln_fem = ln(ec_emp_f + 1)
gen ln_pop = ln(pc_tot_p + 1)
gen ec_emp = ec_emp_f + ec_emp_m
gen ln_emp = ln(ec_emp + 1)
gen ln_men_ag = ln(emp_ag + 1)
gen ln_fem_ag = ln(pc_emp_fag + 1)

/* generate linear time trends */
egen state_trend = group(pc11_state_id period)
egen dec_trend = group(dec period)
egen quart_trend = group(quart period)

cap log close
log using $out/district_levels.txt, text replace 

/* A. Log (men ag employed) */
reghdfe ln_men_ag treat_pre treat_post $covar_trends pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_men_ag if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* B. Log (women ag employed) */
reghdfe ln_fem_ag treat_pre treat_post $covar_trends pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_fem_ag if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* C. Log (men non-ag employed) */
reghdfe ln_men treat_pre treat_post $covar_trends pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district) 
sum ln_men if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

/* D. Log (women non-ag employed) */
reghdfe ln_fem treat_pre treat_post $covar_trends pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district) 
sum ln_fem if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

log close 
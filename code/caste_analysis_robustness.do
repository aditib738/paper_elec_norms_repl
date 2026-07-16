/* the current analysis shows results of electrification */
/* interacted with continous caste composition */
/* this do file shows results using 75th percentile thresholds of caste */
/* composition instead */

/* bring in dataset (created in a/flfp_ihds_vill.do) */
use $tmp/caste_robust, clear


/* create 75th percentile thresholds */
foreach c in uc scst {
gen `c'_p75 = `c' >= r(p75)
replace `c'_p75 = . if mi(`c')
gen `c'75_post = `c'_p75 * post
gen elec_`c'75 = treat_post * `c'_p75
}

/* run regressions using 75th percentile threshold */

/*********/
/* SC/ST */
/*********/

reghdfe pc_mainwork_fshare treat_post scst_p75 scst75_post elec_scst75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe pc_main_al_fshare treat_post scst_p75 scst75_post elec_scst75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe pc_main_cl_fshare treat_post scst_p75 scst75_post elec_scst75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe pc_main_ot_fshare treat_post scst_p75 scst75_post elec_scst75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe pc_main_hh_fshare treat_post scst_p75 scst75_post elec_scst75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ec_share_count_own_f treat_post scst_p75 scst75_post elec_scst75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe ec_share_count_f treat_post scst_p75 scst75_post elec_scst75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe ec_share_emp_f treat_post scst_p75 scst75_post elec_scst75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/flfp_scst_p75.csv, keep(elec_scst75) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
scst_p75 "SC/ST p75" scst_post "SC/ST p75 x 1[2011]" ///
elec_scst75 "SC/ST p75 x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

/***************/
/* UC analysis */
/***************/

reghdfe pc_mainwork_fshare treat_post uc_p75 uc75_post elec_uc75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe pc_main_al_fshare treat_post uc_p75 uc75_post elec_uc75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe pc_main_cl_fshare treat_post uc_p75 uc75_post elec_uc75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe pc_main_ot_fshare treat_post uc_p75 uc75_post elec_uc75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe pc_main_hh_fshare treat_post uc_p75 uc75_post elec_uc75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ec_share_count_own_f treat_post uc_p75 uc75_post elec_uc75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe ec_share_count_f treat_post uc_p75 uc75_post elec_uc75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe ec_share_emp_f treat_post uc_p75 uc75_post elec_uc75 [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/flfp_uc_p75.csv, keep(elec_uc75) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
uc_p75 "UC p75" uc_post "UC p75 x 1[2011]" ///
elec_uc75 "UC p75 x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

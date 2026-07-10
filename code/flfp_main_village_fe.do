/* import dataset */
use $tmp/elec_analysis, clear

/* generate variable for treat_post */
gen treat_post = treat * post
gen pre = period == 0
gen treat_pre = treat * pre

/* generate linear time trends */
egen district = group(pc11_state_id pc11_district_id)
egen state_trend = group(pc11_state_id period)
egen dec_trend = group(dec period)
egen quart_trend = group(quart period)

/* drop UTs */
drop if inlist(pc11_state_name, "chandigarh", "andaman nicobar islands", ///
 "dadra nagar haveli", "daman diu", "goa", "lakshadweep", "puducherry")

/* create population */
gen pop = pc_tot_p if period == 1
replace pop = 0 if mi(pop)
sort shrid2 pop
drop pc_tot_p
bys shrid2: egen pc_tot_p = max(pop)
drop pop

/****************/
/* All villages */
/****************/

/* first do it with outcomes already in data */
/* A. pc_mainwork_fshare */
reghdfe pc_mainwork_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(shrid2 period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* B. pc_main_al_fshare */
reghdfe pc_main_al_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(shrid2 period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* C. pc_main_cl_fshare */
reghdfe pc_main_cl_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(shrid2 period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

/* D. pc_main_ot_fshare */
reghdfe pc_main_ot_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(shrid2 period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

/* E. pc_main_hh_fshare */
reghdfe pc_main_hh_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(shrid2 period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

/* F. ec_share_count_own_f */
reghdfe ec_share_count_own_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(shrid2 period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

/* G. ec_share_count_f */
reghdfe ec_share_count_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(shrid2 period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

/* H. ec_share_emp_f */
reghdfe ec_share_emp_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(shrid2 period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

/* store in nice table */
esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/flfp_main_all_villfe.csv, drop(_cons) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_pre "1[10th-Plan district] x 1[1991]" treat_post "1[10th-Plan district] x 1[2011]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

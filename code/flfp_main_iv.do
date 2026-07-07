/* iv version to go from itt to late/ate */
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

/* drop 1991 period */
drop if period == 0

/* generate access to power variable (endogenous) */
gen power_any = 0
replace power_any = 1 if pc_power_all == 1
replace power_any = 1 if pc_power_dom == 1
replace power_any = 1 if pc_power_supl == 1
replace power_any = 1 if pc_power_com == 1
replace power_any = 1 if pc_power_agr == 1

/* first stage */
reghdfe power_any treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
local cm 12.23
estadd local fs "`cm'"
estimates store fs
predict elec_inst

/* tsls */
reghdfe pc_mainwork_fshare elec_inst  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store t1

reghdfe pc_main_al_fshare elec_inst  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store t2

reghdfe pc_main_cl_fshare elec_inst  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store t3

reghdfe pc_main_ot_fshare elec_inst  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store t4

reghdfe pc_main_hh_fshare elec_inst  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store t5

reghdfe ec_share_count_own_f elec_inst  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store t6

reghdfe ec_share_count_f elec_inst  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store t7

reghdfe ec_share_emp_f elec_inst  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store t8

/* store in nice table */
esttab fs t1 t2 t3 t4 t5 t8 t6 t7 using ///
$out/flfp_main_iv.csv, drop(_cons) ///
mlabel("First stage" "Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011] elec_inst "Electricity access (instrumented)"") ///
scalar("fs F-stat" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

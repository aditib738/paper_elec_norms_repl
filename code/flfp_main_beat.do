/* this do file interacts effects of rural electrification */
/* by baseline violence attitudes */
use $tmp/ihds_beat, clear

/* keep only unique obs */
duplicates tag pc11_state_id pc11_district_id, gen(tag)
keep if tag == 0
drop tag

save $tmp/ihds_beat_unique, replace
 
/* merge with analysis dataset */
merge 1:m pc11_state_id pc11_district_id using $tmp/elec_analysis, keep(match) nogen

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

/* create population */
gen pop = pc_tot_p if period == 1
replace pop = 0 if mi(pop)
sort shrid2 pop
drop pc_tot_p
bys shrid2: egen pc_tot_p = max(pop)
drop pop

/* drop pre treatment period */
drop if period == 0

/****************************/
/* Beating justified: Index */
/****************************/

/* generate interactions */
gen beat_post = beat_index * post
gen elec_beat = treat_post * beat_index

reghdfe pc_mainwork_fshare treat_post beat_post elec_beat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe pc_main_al_fshare treat_post beat_post elec_beat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe pc_main_cl_fshare treat_post beat_post elec_beat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe pc_main_ot_fshare treat_post beat_post elec_beat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe pc_main_hh_fshare treat_post beat_post elec_beat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ec_share_count_own_f treat_post beat_post elec_beat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe ec_share_count_f treat_post beat_post elec_beat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe ec_share_emp_f treat_post beat_post elec_beat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/flfp_beat_village.csv, drop(_cons) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
beat_post "Beat just. (index) x 1[2011]" ///
elec_beat "Beat just. (index) x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

coefplot m1 m2 m3 m5 m6 m7 m8, yline(0, lcolor(red) lpattern(-.)) keep(elec_beat) level(90) ///
 vertical ///
legend(order(2 "Total" ///
4 "Ag labor" ///
6 "Cultivators" ///
8 "HH industry" ///
10 "Firm owners" ///
12 "Female hiring firms" ///
14 "Non-ag")) legend(size(small)) xlabel(none) name(a, replace) ///
title("Beating justification (Index)")

/****************************/
/* Beating justified: Dummy */
/****************************/

/* generate interactions */
gen dbeat_post = beat_dummy * post
gen elec_dbeat = treat_post * beat_dummy

reghdfe pc_mainwork_fshare treat_post dbeat_post elec_dbeat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe pc_main_al_fshare treat_post dbeat_post elec_dbeat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe pc_main_cl_fshare treat_post dbeat_post elec_dbeat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe pc_main_ot_fshare treat_post dbeat_post elec_dbeat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe pc_main_hh_fshare treat_post dbeat_post elec_dbeat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ec_share_count_own_f treat_post dbeat_post elec_dbeat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe ec_share_count_f treat_post dbeat_post elec_dbeat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe ec_share_emp_f treat_post dbeat_post elec_dbeat [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/flfp_dbeat_village.csv, drop(_cons) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
dbeat_post "Beating just. (dummy) x 1[2011]" ///
elec_dbeat "Beating just. (dummy) x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

coefplot m1 m2 m3 m5 m6 m7 m8, yline(0, lcolor(red) lpattern(-.)) keep(elec_dbeat) level(90) ///
 vertical ///
legend(order(2 "Total" ///
4 "Ag labor" ///
6 "Cultivators" ///
8 "HH industry" ///
10 "Firm owners" ///
12 "Female hiring firms" ///
14 "Non-ag")) legend(size(small)) xlabel(none) name(b, replace) ///
title("Beating justification (Dummy)")

/* combine graphs */
grc1leg a b, ycommon
graph export $out/elec_beat.pdf, replace
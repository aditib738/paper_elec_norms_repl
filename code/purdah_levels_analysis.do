/* create interacted results with baseline muslim population share */
/* import data */
use $tmp/ihds_dist_analysis, clear

/* keep only period 1 */
keep if period == 1

/* keep only unique obs */
duplicates tag pc11_state_id pc11_district_id, gen(tag)
keep if tag == 0
drop tag

/* drop period */
drop period

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

/* baseline muslim population share */
gen mus_05 = group6 >= 0.25 if period == 1
replace mus_05 = 0 if mi(mus_05)
bys shrid2: egen mus = max(mus_05)

/* keep only muslim dominated districts */
keep if mus == 1

/* generate treatment pre */
gen pre = period == 0
gen treat_pre = treat * pre

/* generate baseline veiling share */
ren purdah_05 purdah
gen purdah_post = purdah * post
gen elec_purdah = treat_post * purdah
gen purdah_pre = purdah * pre
gen elec_purdah_pre = treat_pre * purdah

/* create level outcomes */
gen ln_mainwork_f = ln(pc_mainwork_f + 1)
gen ln_mainwork_m = ln(pc_mainwork_m + 1)
gen ln_al_f = ln(pc_main_al_f + 1)
gen ln_al_m = ln(pc_main_al_m + 1)
gen ln_cl_f = ln(pc_main_cl_f + 1)
gen ln_cl_m = ln(pc_main_cl_m + 1)
gen ln_nag_f = ln(ec_emp_f + 1)
gen ln_nag_m = ln(ec_emp_m + 1)

reghdfe ln_mainwork_f pc_f purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_mainwork_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe ln_mainwork_m pc_m purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_mainwork_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe ln_al_f pc_f purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_al_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe ln_al_m pc_m purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_al_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe ln_cl_f pc_f purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_cl_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ln_cl_m pc_m purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ln_cl_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

esttab m1 m2 m3 m4 m5 m6  using ///
$out/flfp_mus_purdah_village_levels.csv, drop(_cons) ///
coeflabel(treat_pre "1[10th-Plan district] x 1[1991]" treat_post "1[10th-Plan district] x 1[2011]" ///
purdah "1[Purdah]" purdah_post "1[Purdah] x 1[2011]" ///
elec_purdah "1[Purdah] x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

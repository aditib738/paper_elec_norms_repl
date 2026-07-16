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

reghdfe pc_mainwork_fshare purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe pc_main_al_fshare purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe pc_main_cl_fshare purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe pc_main_ot_fshare purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe pc_main_hh_fshare purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ec_share_count_own_f purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe ec_share_count_f purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe ec_share_emp_f purdah_pre elec_purdah_pre treat_pre treat_post purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/flfp_mus_purdah_village.csv, drop(_cons) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_pre "1[10th-Plan district] x 1[1991]" treat_post "1[10th-Plan district] x 1[2011]" ///
purdah "1[Purdah]" purdah_post "1[Purdah] x 1[2011]" ///
elec_purdah "1[Purdah] x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

/* with covars interacted with period fe */
/* merge */
merge m:1 shrid2 using $tmp/ec_working, keep(match) nogen

/* generate interactions */
gen treat_base_share = base_fem_share*treat_post
gen base_post = base_fem_share*post

/* merge with covars */
ren shrid1 shrid
merge m:1 shrid using $tmp/covars, keep(match) nogen

/* create interactions */
ren pc01_vd_* *
global covars t_p m_sch s_sch s_s_sch college hosp tot_exp tot_irr tar_road dist_town
foreach var of var $covars {
gen pre_`var' = pre * `var'
gen post_`var' = post * `var'
}

global covar_trends pre_* post_*

reghdfe pc_mainwork_fshare purdah_pre elec_purdah_pre treat_pre treat_post $covar_trends purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe pc_main_al_fshare purdah_pre elec_purdah_pre treat_pre treat_post $covar_trends purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe pc_main_cl_fshare purdah_pre elec_purdah_pre treat_pre treat_post $covar_trends purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe pc_main_ot_fshare purdah_pre elec_purdah_pre treat_pre treat_post $covar_trends purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe pc_main_hh_fshare purdah_pre elec_purdah_pre treat_pre treat_post $covar_trends purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ec_share_count_own_f purdah_pre elec_purdah_pre treat_pre treat_post $covar_trends purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

reghdfe ec_share_count_f purdah_pre elec_purdah_pre treat_pre treat_post $covar_trends purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

reghdfe ec_share_emp_f purdah_pre elec_purdah_pre treat_pre treat_post $covar_trends purdah purdah_post elec_purdah [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) cluster(district) 
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/controls_int/flfp_mus_purdah_village.csv, drop(_cons) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_pre "1[10th-Plan district] x 1[1991]" treat_post "1[10th-Plan district] x 1[2011]" ///
purdah "1[Purdah]" purdah_post "1[Purdah] x 1[2011]" ///
elec_purdah "1[Purdah] x 1[2011] x 1[10th-Plan district]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace


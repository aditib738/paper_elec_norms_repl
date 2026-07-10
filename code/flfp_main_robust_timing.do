/* run the version of the main did but restricted */
/* to two sets of controls */
/* based on when projects were actually completed */

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

/* flag controls set 1: less than 2% project completion as of start of 2012 */
gen flag = ///
    inlist(pc11_district_id, 4, 5, 10, 2, 24, 25, 26, 27, 28, 29) | ///
    inlist(pc11_district_id, 30, 31, 32, 33, 34, 49, 36, 37, 38, 51) | ///
    inlist(pc11_district_id, 40, 41, 53, 48, 47, 78, 79, 81, 84, 85) | ///
    inlist(pc11_district_id, 87, 125, 247, 254, 270, 268, 271, 281, 282, 283) | ///
    inlist(pc11_district_id, 284, 288, 292, 314, 362, 364, 356, 370, 371, 372) | ///
    inlist(pc11_district_id, 373, 376, 378, 380, 383, 390, 393, 394, 395, 398) | ///
    inlist(pc11_district_id, 401, 403, 404, 406, 414, 418, 422, 424, 434, 464) | ///
    inlist(pc11_district_id, 448, 452, 453, 469, 470, 471, 472, 473, 474, 477) | ///
    inlist(pc11_district_id, 478, 479, 480, 482, 483, 485, 486, 492, 489, 490) | ///
    inlist(pc11_district_id, 491, 499, 500, 501, 502, 510, 512, 513, 515, 516) | ///
    inlist(pc11_district_id, 520, 523, 524, 525, 528, 529, 531, 534, 540, 545) | ///
    inlist(pc11_district_id, 568, 570, 576, 578, 588, 589, 590, 591, 592, 593) | ///
    inlist(pc11_district_id, 602, 604, 605, 606, 607, 608, 609, 610, 632, 612) | ///
    inlist(pc11_district_id, 613, 615, 617, 618, 619, 620, 621, 622, 623, 624) | ///
    inlist(pc11_district_id, 625, 626, 629, 616, 614, 627)

/* first robustness table */
preserve

drop if flag == 0 & treat == 0

/* A. pc_mainwork_fshare */
reghdfe pc_mainwork_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* B. pc_main_al_fshare */
reghdfe pc_main_al_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* C. pc_main_cl_fshare */
reghdfe pc_main_cl_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

/* D. pc_main_ot_fshare */
reghdfe pc_main_ot_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

/* E. pc_main_hh_fshare */
reghdfe pc_main_hh_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

/* F. ec_share_count_own_f */
reghdfe ec_share_count_own_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

/* G. ec_share_count_f */
reghdfe ec_share_count_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

/* H. ec_share_emp_f */
reghdfe ec_share_emp_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

/* store in nice table */
esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/flfp_main_all_r1.csv, drop(_cons) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_pre "1[10th-Plan district] x 1[1991]" treat_post "1[10th-Plan district] x 1[2011]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

restore

/* flag controls set 2: less than 2% project completion as of start of 2013 */
drop flag
gen flag = ///
    inlist(pc11_district_id, 4, 26, 28, 29, 30, 32, 33, 49, 36, 37) | ///
    inlist(pc11_district_id, 38, 51, 40, 41, 53, 48, 47, 78, 81, 84) | ///
    inlist(pc11_district_id, 85, 87, 282, 283, 288, 292, 314, 376, 422, 452) | ///
    inlist(pc11_district_id, 469, 470, 471, 483, 485, 486, 489, 490, 491, 534) | ///
    inlist(pc11_district_id, 540, 545, 568, 570, 576, 588, 589, 591, 602, 604) | ///
    inlist(pc11_district_id, 605, 606, 607, 608, 609, 610, 632, 612, 613, 615) | ///
    inlist(pc11_district_id, 617, 618, 619, 620, 621, 622, 623, 624, 625, 626) | ///
    inlist(pc11_district_id, 629, 616, 614, 627)


preserve

drop if flag == 0 & treat == 0

/* A. pc_mainwork_fshare */
reghdfe pc_mainwork_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* B. pc_main_al_fshare */
reghdfe pc_main_al_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* C. pc_main_cl_fshare */
reghdfe pc_main_cl_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

/* D. pc_main_ot_fshare */
reghdfe pc_main_ot_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

/* E. pc_main_hh_fshare */
reghdfe pc_main_hh_fshare treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

/* F. ec_share_count_own_f */
reghdfe ec_share_count_own_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

/* G. ec_share_count_f */
reghdfe ec_share_count_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

/* H. ec_share_emp_f */
reghdfe ec_share_emp_f treat_pre treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

/* store in nice table */
esttab m1 m2 m3 m4 m5 m8 m6 m7 using ///
$out/flfp_main_all_r2.csv, drop(_cons) ///
mlabel("Main workers" ///
"Ag labor" "Cultivators" ///
"Other" "Household" "Non-farm" "Firm owners" "Firms employ women") ///
coeflabel(treat_pre "1[10th-Plan district] x 1[1991]" treat_post "1[10th-Plan district] x 1[2011]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace

restore
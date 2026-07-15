use $tmp/ed_mech_analysis, clear

/* generate interactions */
gen treat_post_enr = girls_share*treat_post
gen enr_post = girls_share*post

/* total girls enrollment? */
sum enr_all_g, d
gen enr_share = enr_all_g/pc_f
replace enr_share = . if enr_share > 1
gen treat_post_girls = enr_share * treat_post
gen girls_en_post = enr_share * post

estimates clear

/* run main regressions */
reghdfe pc_mainwork_fshare enr_post treat_post_enr treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_mainwork_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* B. pc_main_al_fshare */
reghdfe pc_main_al_fshare enr_post treat_post_enr treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_al_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* C. pc_main_cl_fshare */
reghdfe pc_main_cl_fshare enr_post treat_post_enr treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_cl_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

/* D. pc_main_ot_fshare */
reghdfe pc_main_ot_fshare enr_post treat_post_enr treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_ot_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

/* E. pc_main_hh_fshare */
reghdfe pc_main_hh_fshare enr_post treat_post_enr treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum pc_main_hh_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

/* F. ec_share_count_own_f */
reghdfe ec_share_count_own_f enr_post treat_post_enr treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

/* G. ec_share_count_f */
reghdfe ec_share_count_f enr_post treat_post_enr treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m7

/* H. ec_share_emp_f */
reghdfe ec_share_emp_f enr_post treat_post_enr treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m8

/* save coefplot */
set scheme white_tableau
coefplot m1 m2 m3 m5 m6 m8 m7, yline(0, lcolor(red) lpattern(-.)) ///
keep(treat_post_enr) level(90) vertical ylabel(-.1 (.1) .2) ///
legend(subtitle("Female share of:") order(2 "Overall labor force" 4 "Agricultural labor" ///
6 "Cultivators" 8 "HH industries" ///
10 "Firm owners" 12 "Non-ag labor force" 14 "Share of firms employing women") size(small)) ///
xlabel(none) msize(large) subtitle("Coefficients: Treatment x baseline female % of school enrollment") 
graph export $out/enr_coefs.pdf, replace

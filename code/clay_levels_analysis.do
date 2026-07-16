use $tmp/soil_analysis, clear

/* generate interactions */
gen elec_clay = treat_post * clay
gen clay_post = clay * post
gen pre = period == 0
gen treat_pre = treat * pre
gen clay_pre = clay*pre
gen elec_clay_pre = treat_pre * clay


foreach g in f m {
gen ln_non_ag_`g' = ln(ec_emp_`g' + 1)
gen ln_non_ag_hh_`g' = ln(pc_main_hh_`g' + 1)
gen ln_non_ag_ot_`g' = ln(pc_main_ot_`g' + 1)

gen own_`g' = ec13_count_own_`g' if period == 2
replace own_`g' = ec05_count_own_`g' if period == 1
replace own_`g' = ec98_count_own_`g' if period == 0
gen any_own_`g' = own_`g' > 0 & !mi(own_`g')
gen ln_own_`g' = ln(own_`g' + 1)
}

reghdfe any_own_f treat_pre clay_pre elec_clay_pre clay clay_post treat_post elec_clay pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum any_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe any_own_m treat_pre clay_pre elec_clay_pre clay clay_post treat_post elec_clay pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum any_own_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe ln_own_f treat_pre clay_pre elec_clay_pre clay clay_post treat_post elec_clay pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_own_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe ln_own_m treat_pre clay_pre elec_clay_pre clay clay_post treat_post elec_clay pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_own_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

/* store in nice table */
esttab m1 m2 m3 m4 using ///
$out/flfp_main_clay_levels.csv, drop(_cons) ///
coeflabel(treat_post "1[10th-Plan district] x 1[2011]" ///
elec_clay "1[10th-Plan district] x 1[2011] x Clay content") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace 

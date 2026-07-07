/* split up share analysis by levels */
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
drop if mi(dec)

/* drop UTs */
drop if inlist(pc11_state_name, "chandigarh", "andaman nicobar islands", ///
 "dadra nagar haveli", "daman diu", "goa", "lakshadweep", "puducherry")

/* create population */
gen pop = pc_tot_p if period == 1
replace pop = 0 if mi(pop)
sort shrid2 pop
ren pc_tot_p population
bys shrid2: egen pc_tot_p = max(pop)

/* A. Log (men ag employed) */
reghdfe ln_men_ag treat_pre treat_post pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_men_ag if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* B. Log (women ag employed) */
reghdfe ln_fem_ag treat_pre treat_post pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_fem_ag if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* C. Log (men non-ag employed) */
reghdfe ln_men treat_pre treat_post pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district) 
sum ln_men if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

/* D. Log (women non-ag employed) */
reghdfe ln_fem treat_pre treat_post pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district) 
sum ln_fem if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

/* store in nice table */
esttab m1 m2 m3 m4 using ///
$out/flfp_main_levels.tex, drop(_cons) ///
mlabel("Ln(employed men - Ag)" "Ln(employed women - Ag)" ///
"Ln(employed men - Non-ag)" "Ln(employed women - Non-ag)") ///
coeflabel(treat_pre "1[10th-Plan district] x 1[1991]" treat_post "1[10th-Plan district] x 1[2011]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace


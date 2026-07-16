/* robustness to check balance on caste, other norm variables */

/* import data */
use $tmp/ihds_dist_analysis, clear

/* keep only unique obs */
duplicates tag pc11_state_id pc11_district_id period, gen(tag)
keep if tag == 0
drop tag

/* merge consumption per capita */
merge 1:m pc11_state_id pc11_district_id period using $tmp/elec_analysis, keep(match) nogen

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

/* drop pre treatment period */
drop if period == 0

/* create population */
gen pop = pc_tot_p if period == 1
replace pop = 0 if mi(pop)
sort shrid2 pop
drop pc_tot_p
bys shrid2: egen pc_tot_p = max(pop)
drop pop

/* merge soil dataset */
merge 1:1 shrid2 period using $tmp/soil_analysis, keepusing(clay period) keep(master match) nogen

/* keep only first period */
keep if period == 1

/* vars of interest */
drop uc
gen uc = group1 + group2

/* generate muslim dummy */
gen mus_05 = group6 >= 0.25
ren purdah purdah_all
gen purdah_mus = purdah_all if mus == 1

/* label */
la var uc "Upper caste %"
la var scst "SC-ST caste %"
la var purdah_mus "Purdah % (Muslim)"
la var purdah_all "Purdah (all)"

/* run regressions */
reghdfe treat uc [pw = pc_tot_p], ///
absorb(dec quart) ///
cluster(district)
estimates store upper_caste

reghdfe treat scst [pw = pc_tot_p], ///
absorb(dec quart) ///
cluster(district)
estimates store marginalized_caste

reghdfe treat purdah_mus  [pw = pc_tot_p], ///
absorb(dec quart) ///
cluster(district)
estimates store purdah_muslim

reghdfe treat purdah_all [pw = pc_tot_p], ///
absorb(dec quart) ///
cluster(district)
estimates store purdah_all

set scheme white_tableau
coefplot upper_caste marginalized_caste ///
purdah_all purdah_muslim, ///
drop(_cons) xline(0)

graph export $out/balance.png, replace 






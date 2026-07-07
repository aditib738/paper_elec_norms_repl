/* Prep economic census data to do analysis separately by firm owner */
/* gender to speak to Chiplunkar results */

/* bring in analysis dataset */
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
drop pc_tot_p
bys shrid2: egen pc_tot_p = max(pop)
drop pop

/* drop pre period */
drop if period == 0

/* merge */
merge m:1 shrid2 using $tmp/ec_working, keep(match) nogen

/* generate interactions */
gen treat_base_share = base_fem_share*treat_post
gen base_post = base_fem_share*post

/*******************/
/* Run regressions */
/*******************/

/* outcome: female share of non ag labor force */
reghdfe ec_share_emp_f base_post treat_base_share treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum base_fem_share if e(sample) == 1 
local mean = `r(mean)'
local dm: di %9.2f `mean' 
estadd local dm "`dm'"
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* outcome: share of firms employing women */
reghdfe ec_share_count_f base_post treat_base_share treat_post  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum base_fem_share if e(sample) == 1 
local mean = `r(mean)'
local dm: di %9.2f `mean' 
estadd local dm "`dm'"
sum ec_share_count_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* store in nice table */
esttab m1 m2 using ///
$out/flfp_firm_owner_dynamic.tex, drop(_cons) ///
mlabel("Female non-ag labor force \%"  "\% of firms employing women") ///
coeflabel(base_post "Baseline female share: firm owners x 1[2011]" ///
treat_post "1[10th-Plan district] x 1[2011]" ///
treat_base_share "Treatment x Baseline female firm owners x 1[2011]") ///
scalar("cm Mean of dep var" "dm Mean of female-firm owner \%" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace







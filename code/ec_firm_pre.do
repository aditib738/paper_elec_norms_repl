/* run pretrends test on firm ownership interaction analysis */
/* Prep economic census data to do analysis separately by firm owner */
/* gender to speak to Chiplunkar results */

/* only use economic census outcomes for this analysis */

/* first prep ec05 data for this */

/* import dataset */
use ~/data/ec05_shrid, clear

/* create new variables */
gen base_fem_share = ec05_count_own_f/ec05_count_all

/* keep variables of interest */
keep base* shrid2

/* compress and save */
compress
save $tmp/ec_working, replace

/* bring in analysis dataset */
use $tmp/main_analysis, clear

/* merge */
merge m:1 shrid2 using $tmp/ec_working, keep(match) nogen

/* generate interactions */
gen treat_base_share = base_fem_share*treat_pre
gen base_pre = base_fem_share*pre

global covar_trends pre_* 
drop if period == 2

/*******************/
/* Run regressions */
/*******************/

/* outcome: female share of non ag labor force */
reghdfe ec_share_emp_f base_pre treat_pre treat_base_share $covar_trends [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum base_fem_share if e(sample) == 1 
local mean = `r(mean)'
local dm: di %9.2f `mean' 
estadd local dm "`dm'"
sum ec_share_emp_f if e(sample) == 1 & treat == 0 & pre == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

/* outcome: share of firms employing women */
reghdfe ec_share_count_f base_pre treat_base_share treat_pre $covar_trends  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum base_fem_share if e(sample) == 1 
local mean = `r(mean)'
local dm: di %9.2f `mean' 
estadd local dm "`dm'"
sum ec_share_count_f if e(sample) == 1 & treat == 0 & pre == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

/* store in nice table */
esttab m1 m2 using ///
$out/flfp_firm_owner_dynamic_pre.tex, drop(_cons) ///
mlabel("Female non-ag labor force \%"  "\% of firms employing women") ///
coeflabel(base_pre "Baseline female share: firm owners x 1[1991]" ///
treat_pre "1[10th-Plan district] x 1[1991]" ///
treat_base_share "Treatment x Baseline female firm owners x 1[1991]") ///
scalar("cm Mean of dep var" "dm Mean of female-firm owner \%" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace







*==============================================================*
*  Matched DiD robustness (R2)
*  Match 10th-Plan (treat) districts to 11th-Plan (control)
*  districts on baseline covariates; run the identical village
*  DiD on the matched subsample.
*  Requires: ssc install psmatch2 ; ssc install reghdfe ftools
*==============================================================*

use $tmp/robustness_analysis, clear
// file built by main_robustness.do

* --- Matching covariates (2001 baseline) ---
global match_covars t_p m_sch s_sch s_s_sch college hosp ///
                    tot_exp tot_irr tar_road dist_town

*--------------------------------------------------------------*
* 1. District-level baseline cross-section
*--------------------------------------------------------------*
preserve
keep if period == 1                      
collapse (mean) $match_covars [aw = pc_tot_p], ///
         by(district treat pc11_state_id)

*--------------------------------------------------------------*
* 2. Propensity score (district is 10th-Plan); state FE = compare
*    like-with-like within state
*--------------------------------------------------------------*
logit treat $match_covars 
predict pscore, pr

*--------------------------------------------------------------*
* 3. 1:1 NN match, caliper, no replacement, common support.
*--------------------------------------------------------------*
set seed 738738
gen double _u = runiform()
sort _u
// NN-no-replacement is order-sensitive

psmatch2 treat, pscore(pscore) neighbor(1) caliper(0.10) ///
         common noreplacement

pstest $match_covars, both
// standardised %bias before/after

tab treat if mi(_weight)
tab treat if !mi(_weight)

keep if _weight != .
// matched districts only
keep district
tempfile matched_dist
save `matched_dist'
restore

*--------------------------------------------------------------*
* 4. Flag matched districts in the village panel
*--------------------------------------------------------------*
merge m:1 district using `matched_dist', keep(match) nogen

*--------------------------------------------------------------*
* 5. IDENTICAL DiD on the matched subsample.
*--------------------------------------------------------------*
local outcomes pc_mainwork_fshare pc_main_al_fshare pc_main_cl_fshare ///
               pc_main_ot_fshare pc_main_hh_fshare ///
               ec_share_count_own_f ec_share_count_f ec_share_emp_f

local i = 0
foreach y of local outcomes {
    local ++i
    reghdfe `y' treat_pre treat_post [pw = pc_tot_p], ///
        absorb(district period state_trend dec_trend quart_trend) ///
        cluster(district)
    sum `y' if e(sample) == 1 & treat == 0 & post == 1
    local cm : di %9.2f r(mean)
    estadd local cm "`cm'"
    estimates store mm`i'
}

esttab mm1 mm2 mm3 mm4 mm5 mm6 mm7 mm8 using $out/matched_did.tex, ///
    keep(treat_pre treat_post) se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(cm N, labels("Mean dep var" "N")) ///
    mtitles("Main" "Ag lab" "Cult" "Other" "HH" "Oeners" "Emp women" "Non-ag") replace
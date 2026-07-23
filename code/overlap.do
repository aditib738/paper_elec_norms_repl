/* prep caste data */
use $tmp/ihds_dist_analysis, clear

/* keep only unique obs */
keep if period == 1
duplicates tag pc11_state_id pc11_district_id, gen(tag)
keep if tag == 0
drop tag

/* muslim sample */
gen mus_05 = group6 >= 0.25 if period == 1
replace mus_05 = 0 if mi(mus_05)

/* keep what you need */
keep scst uc purdah_05 pc11_state_id pc11_district_id mus_05

/* destring ids */
destring pc11_state_id pc11_district_id , replace 

/* save */
tempfile ihds
save `ihds', replace

/* prep soil */
use $tmp/soil_analysis, clear

/* merge */
merge m:1 pc11_state_id pc11_district_id using `ihds'

/* collapse clay */
collapse (mean) mus  clay scst purdah uc, by(pc11_state_id pc11_district_id)

/* rename */
ren uc uc_share
ren scst scst_share
ren purdah purdah_share
ren mus mus_dominant
ren clay clay_share

label var uc_share      "Upper caste share"
label var scst_share    "SC/ST share"
label var purdah_share  "Purdah compliance"
label var clay_share    "Clay share"
label var mus_dominant  "Muslim dominance"

* Panel A: pairwise correlations, all districts
pwcorr uc_share scst_share purdah_share clay_share mus_dominant, sig obs

* Panel B: purdah subsample vs. full sample
tabstat uc_share scst_share purdah_share clay_share mus_dominant ///
    , stat(mean sd n) col(stat)

* Export
estpost tabstat uc_share scst_share mus_dominant purdah_share clay_share, ///
     stat(mean sd n) col(stat)
esttab using "$out/overlap_moderators.csv", replace ///
    cells("mean(fmt(3)) sd(fmt(3)) count(fmt(0))") nomtitle
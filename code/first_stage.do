/* bring in night lights panel */
use $tmp/dmsp_pc11dist.dta, clear

/* merge with treatment status */
destring pc11_state_id pc11_district_id, replace
merge m:1 pc11_state_id pc11_district_id using $tmp/districts_treat, keep(match) nogen

/* define treatment */
gen treat = 1 if inlist(type, 10, 12)
replace treat = 0 if type == 11
replace treat = 0 if type == 99

/* merge population */
/* keep one obs per district year */
collapse_save_labels
collapse (max) dmsp_mean_light_cal (firstnm) treat, by(pc11_state_id pc11_district_id year)
collapse_apply_labels

/* create event study plot */

/* generate treatment_year */
gen temp = 2005
replace temp = 9999 if treat == 0

/* generate distance to treatment */
gen dist = year - temp

/* make sure untreated get dist = -1 */
replace dist = -1 if temp == 9999

/* omit -1 from regression */
char dist[omit] -1

/* generate district dummy */
egen district = group(pc11_state_id pc11_district_id)

/* create regression coefficients */
xi i.dist, pref(_T)
xi: reghdfe dmsp_mean_light_cal i.dist, absorb(pc11_state_id pc11_district_id year) vce(cluster district)

/* create event study graph */
preserve
regsave
list
// gen ci intervals
gen ci_upper = coef - (1.645 * stderr)
gen ci_lower = coef + (1.645 * stderr) 

// drop constant
drop if var == "_cons"

// generate distance variable
gen id = _n
keep if inrange(id, 7, 17)
gen dist = 1993 + id if inrange(id, 7, 10)
replace dist = 1994 + id if inrange(id, 11, 17)

// create plot
set scheme white_tableau
scatter coef ci* dist, c(l l l) cmissing(y n n) ///
msym(i i i) lcolor(gray gray gray) lpattern(solid dash dash) ///
lwidth(thick medthick medthick) yline(0, lcolor(black)) ///
xline(2004.85, lcolor(black)) legend(off) ///
subtitle("DID coefficient: Night lights", size(medium)) ///
ylabel(, nogrid angle(horizontal) labsize(medsmall)) ///
xtitle("Year [Note: Fifth Year Plan rolled out in 2005]", size(small)) ///
xlabel(2000 (1) 2011, labsize(small)) scheme(white_tableau)

// save graph
graph export "$out/event_study.png", replace

restore


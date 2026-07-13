/*********************************************************/
/* This do file creates graph versions of the main India */
/* FLFP result                                           */
/*********************************************************/

/* PROGRAM TO STORE RESULTS FROM REGRESSIONS FOR GRAPH */
cap prog drop makegraph
prog def makegraph, rclass

clear
set obs 4
gen k = _n 
gen beta = .
gen se = .

/* plot coefficients and standard erros */
replace beta = _b[treat_pre_pre] in 1
replace beta = _b[treat_pre] in 2
replace beta = 0 in 3
replace beta = _b[treat_post] in 4

replace se = _se[treat_pre_pre] in 1
replace se = _se[treat_pre] in 2
replace se = 0 in 3
replace se = _se[treat_post] in 4

replace k = 1990 in 1
replace k = 1998 in 2
replace k = 2005 in 3
replace k = 2013 in 4

gen lbound=beta-1.645*se
gen ubound=beta+1.645*se

end
/**********************************END PROGRAM MAKEGRAPH*******************************/

/* prepare main data */
use $tmp/elec_analysis, clear

keep if period == 1
keep pc11_state_id pc11_district_id shrid1 pc_tot_p dec quart shrid2 treat
duplicates drop

compress
save $tmp/fm, replace

/* prepare 1990 data */
use $tmp/shrug_ec90, clear

/* outcomes */
gen ec_share_emp_f = ec90_emp_f/(ec90_emp_f + ec90_emp_m)
gen ec_share_count_f = ec90_count_f/ec90_count_all

/* keep only rural */
keep if ec90_sector == 2

/* keep only data needd */
keep shrid ec_share*

/* generate period */
gen period = -1

/* merge with main dataset */
/* keep dec quart pc_tot_p */
ren shrid shrid1
merge 1:m shrid1 using $tmp/fm, keepusing(pc_tot_p dec quart shrid2 pc11_state_id pc11_district_id treat) keep(match) nogen
duplicates drop

/* compress and save */
compress
save $tmp/ec_90_fm, replace

/* import dataset */
use $tmp/elec_analysis, clear

/* drop UTs */
drop if inlist(pc11_state_name, "chandigarh", "andaman nicobar islands", ///
 "dadra nagar haveli", "daman diu", "goa", "lakshadweep", "puducherry")

/* drop vars we don't need */
keep ec_* period shrid2 pc_tot_p treat post pc11_state_id pc11_district_id dec quart 

/* bring in ec90 */
append using $tmp/ec_90_fm
erase $tmp/ec_90_fm.dta

/* generate linear time trends */
egen district = group(pc11_state_id pc11_district_id)
egen state_trend = group(pc11_state_id period)
egen dec_trend = group(dec period)
egen quart_trend = group(quart period)

/* create population */
gen pop = pc_tot_p if period == 1
replace pop = 0 if mi(pop)
sort shrid2 pop
drop pc_tot_p
bys shrid2: egen pc_tot_p = max(pop)
drop pop

/* gen treat pre */
drop post
gen post = period == 2
gen pre = period == 0
gen pre_pre = period == -1
gen treat_pre = treat * pre
gen treat_pre_pre = treat * pre_pre

/* gen treat post */
gen treat_post = treat * post

/* main regression */
reghdfe ec_share_emp_f treat_post treat_pre_pre treat_pre [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)

/* create graph */
preserve
makegraph
twoway (scatter beta k) (rcap ubound lbound k),  ///
xtitle("Year of Observation") ytitle("Coefficient") legend(off) xline(2005) yline(0) xlabel(1981 (10) 2022, nogrid) ///
name(f, replace) title("Female share of non-farm workers") ylabel(-0.02 (0.01) 0.05, nogrid)
restore

/* main regression */
reghdfe ec_share_count_f treat_post treat_pre treat_pre_pre [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)

/* create graph */
preserve
makegraph
twoway (scatter beta k) (rcap ubound lbound k),  xtitle("Year of Observation") ytitle("Coefficient") legend(off) xline(2005) yline(0) xlabel(1981 (10) 2022, nogrid) ///
name(h, replace) title("Share of firms hiring women") ylabel(-0.02 (0.01) 0.05, nogrid)
restore

/* combine graphs */
graph combine f h, ycommon
graph export $out/did_robust.pdf, replace


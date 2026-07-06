/* baseline flfp by social groups */
use $tmp/ihds_05.dta, clear

/* keep only women aged 15-49 */
keep if inrange(RO5, 15, 49)
keep if RO3 == 2

/* gen flfp measure */
gen flfp = WS0N != 0
sum flfp
/* 24% */

/* distribution of flfp by caste category */
set scheme tab2
cibar flfp [pw = SWEIGHT], over(GROUPS8) graphopts(ytitle("FLFP %"))
graph export $out/flfp_groups.pdf, replace

/* distribution of flfp by caste category, conditional on copc */
set scheme tab1
/* create deciles of copc */
xtile cons_decile = COPC, n(5)

/* recode groups */
gen groups = GROUPS8
replace groups = 7 if groups == 8
la define g 1 "Brahmin" 2 "Upper caste" 3 "OBC" 4 "Dalit" 5 "Adivasi" 6 "Muslim" 7 "Others"
la val groups g

cibar flfp [pw = SWEIGHT], over(groups cons_decile) graphopts(ytitle("FLFP %") ylab(, nogrid) xlab(, nogrid) xtitle("Quintile: Consumption per capita") legend(size(small)))
graph export ~/electric_flfp/exhibits/flfp_copc.pdf, replace

/* version of graph above with consolidated caste groups */

/* generate consolidated groups */
gen groups_large = 1 if inlist(groups, 1, 2)
replace groups_large = 3 if inlist(groups, 4, 5)
replace groups_large = 2 if mi(groups_large)
replace groups_large = . if mi(groups)
la define gl 1 "Forward castes" 3 "Marginalized castes" 2 "Other castes/religions"
la val groups_large gl

cibar flfp [pw = SWEIGHT], over(groups_large cons_decile) graphopts(ytitle("FLFP %") ylab(, nogrid) xlab(, nogrid) xtitle("Quintile: Consumption per capita") legend(size(small)))
graph export ~/electric_flfp/exhibits/flfp_copc_large.pdf, replace

/* distribution of key outcomes at baseline */
use $tmp/elec_analysis, clear

/* keep vars of interest */
keep if period == 1
keep ec_share_count_own_f ec_share_emp_f pc_main_al_fshare pc_main_cl_fshare pc_mainwork_fshare

/* generate graph for labor force shares */
sum pc_mainwork_fshare
local main_mean = r(mean)

sum pc_main_cl_fshare
local cl_mean = r(mean)

sum pc_main_al_fshare
local al_mean = r(mean)

sum ec_share_emp_f
local ag_mean = r(mean)

twoway (kdensity pc_mainwork_fshare, color(black)) ///
(kdensity pc_main_al_fshare, color(cyan)) ///
(kdensity pc_main_cl_fshare, color(blue)) ///
(kdensity ec_share_emp_f, color(magenta)), ///
xline(`main_mean', lcolor(black) lpattern(dash)) ///
xline(`al_mean', lcolor(cyan) lpattern(dash)) ///
xline(`cl_mean', lcolor(blue) lpattern(dash)) ///
xline(`ag_mean', lcolor(magenta) lpattern(dash)) ///
xtitle(Female Share of Labor Force (Baseline)) ///
ytitle(Density) ///
bgcolor(white) graphregion(color(white)) ///
legend(order(1 "Overall labor force" 2 "Ag Labor" 3 "Cultivators" 4 "Non-ag Labor"))
graph export $out/base_dist.pdf, replace

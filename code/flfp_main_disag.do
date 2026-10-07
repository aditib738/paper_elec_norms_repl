/* this do file runs the main flfp analysis at a disaggregated sector level */

/******************/
/* Pre-processing */
/******************/

/* import dataset */
use $tmp/main_analysis, clear

global covar_trends pre_* post_*

/***************/
/* Regressions */
/***************/

reghdfe emp_man_fshare treat_pre treat_post $covar_trends  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum emp_man_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m1

reghdfe ln_man_emp_m treat_pre treat_post $covar_trends pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_man_emp_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m2

reghdfe ln_man_emp_f treat_pre treat_post $covar_trends pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_man_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m3

reghdfe emp_serv_fshare treat_pre treat_post $covar_trends  [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum emp_serv_fshare if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m4

reghdfe ln_serv_emp_m treat_pre treat_post $covar_trends pc_m [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_serv_emp_m if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m5

reghdfe ln_serv_emp_f treat_pre treat_post $covar_trends pc_f [pw = pc_tot_p], ///
absorb(district period state_trend dec_trend quart_trend) ///
cluster(district)
sum ln_serv_emp_f if e(sample) == 1 & treat == 0 & post == 1
local mean = `r(mean)'
local cm: di %9.2f `mean' 
estadd local cm "`cm'"
estimates store m6

/* store in nice table */
esttab m1 m2 m3 m4 m5 m6 using ///
$out/flfp_main_sectors.tex, drop( $covar_trends _cons) ///
mlabel("Female % of Manufacturing LF" ///
"Ln(Male employed)" "Ln(Female employed)" ///
"Female % of Services LF" "Ln(Male employed)" "Ln(Female employed)") ///
coeflabel(treat_pre "1[10th-Plan district] x 1[1991]" treat_post "1[10th-Plan district] x 1[2011]") ///
scalar("cm Mean of dep var" ) ///
star(* 0.10 ** 0.05 *** 0.01) b(3) nonotes se(3) replace


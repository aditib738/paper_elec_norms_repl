/* This master do file calls all the  */
/* necessary do files in sequence */
/* to produce all the tables and figures */
/* in the electrification-norms paper */
/* Bhowmick (2026) */

/* set globals */

/* point to where the data is saved + unzipped */
// global tmp

/* point to where you would like to store exhibits */
global out ~/paper_elec_norms_repl/exhibits

/* point to code folder */
global code ~/paper_elec_norms_repl/code

/* fig 1: treatment and control map of india */
do $code/map_treat.do

/* fig 2 and a.2: baseline flfp and female shares of LF */
do $code/descriptives.do

/* table 1: headline aggregate results, and table a.6: robustness to large villages */
do $code/flfp_main.do

/* table 2: IV table */
do $code/flfp_main_iv.do

/* table 3: levels table, aggregate */
do $code/flfp_main_levels.do

/* table 4: firm ownership dynamic */
do $code/firm_ownership.do

/* table 5: caste analysis */
do $code/flfp_caste_analysis.do

/* table 6: purdah main result */
do $code/purdah_analysis.do
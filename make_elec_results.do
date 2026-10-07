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

/********/
/* Main */
/********/

/* fig 1: treatment and control map of india */
do $code/map_treat.do

/* fig 2, a.3 and a.4: baseline flfp and female shares of LF */
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

/* table 7: clay analysis */
do $code/clay_analysis.do

/* fig */
do $code/flfp_ec_graphs.do

/************/
/* Appendix */
/************/

/* nigtlights map */
do $code/nl_map.do

/* first stage event study */
do $code/first_stage.do

/* treatment timing robustness */
do $code/flfp_main_robust_timing.do

/* village FE */
do $code/flfp_main_village_fe.do

/* q-values */
do $code/qvalues.do

/* honest did */
do $code/matched_did.do

/* female level emp, by sector */
do $code/flfp_main_disag.do

/* firm analysis pretrend */
do $code/ec_firm_pre.do

/* mechanism: home productivity vs market productivity */
do $code/india_mechanisms.do

/* mech: gender parity in enrollment */
do $code/india_mechanisms_ed.do

/* caste pretrends */
do $code/caste_analysis_pretrends.do

/* caste levels */
do $code/caste_analysis_levels.do

/* caste vill fe */
do $code/caste_analysis_vill.do

/* balance */
do $code/flfp_caste_balance.do

/* hh panel analysis */
do $code/hh_panel_analysis.do

/* other norms */
do $code/flfp_main_beat.do

/* map of soil analysis */
do $code/soil_map.do

/* purdah robustness: vill fe */
do $code/purdah_analysis_vill.do

/* purdah robustness: levels*/
do $code/purdah_levels_analysis.do

/* soil pretrends */
do $code/clay_pretrends.do

/* soil vill fe */
do $code/clay_analysis_vill.do

/* clay levels */
do $code/clay_levels_analysis.do

/* district level aggregation */
do $code/main_table_district.do
do $code/levels_table_district.do
do $code/caste_table_district.do
do $code/soil_table_district.do
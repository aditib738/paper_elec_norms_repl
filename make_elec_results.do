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
global code ~/paper_elec_norms/code

/* fig 1: treatment and control map of india */
do $code/map_treat.do
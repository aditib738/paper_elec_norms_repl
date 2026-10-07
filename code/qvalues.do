*===============================================================================
* Two FDR q-value methods, computed per-table (per-family).
*
*   by2001_q        : Benjamini-Yekutieli (2001), == R's p.adjust(method="BY")
*   bky_sharpened_q : Benjamini-Krieger-Yekutieli (2006) sharpened two-stage,
*                     == Anderson (2008) sharpened q-values
*
*===============================================================================

*-------------------------------------------------------------------------------
* PROGRAM 1: BY(2001) -- exact port of R's p.adjust(method="BY")
*-------------------------------------------------------------------------------
capture program drop by2001_q
program define by2001_q
    args pvalvar
    quietly count if `pvalvar' < .
    local n = r(N)
    * harmonic penalty c(n) = sum_{i=1}^{n} 1/i
    local cn = 0
    forvalues i = 1/`n' {
        local cn = `cn' + 1/`i'
    }
    quietly gen long _orig = _n
    * sort ascending; rank 1..n
    quietly sort `pvalvar'
    quietly gen long _rank = _n if `pvalvar' < .
    * raw value: c(n) * (n/rank) * p
    quietly gen double _raw = `cn' * (`n'/_rank) * `pvalvar' if `pvalvar' < .
    * step-up: cumulative MIN running from largest rank down to 1
    quietly gen double by_qval = .
    local run = .
    forvalues r = `n'(-1)1 {
        quietly sum _raw if _rank == `r', meanonly
        local cur = r(mean)
        if `run' == . {
            local run = `cur'
        }
        else {
            local run = min(`run', `cur')
        }
        quietly replace by_qval = `run' if _rank == `r'
    }
    quietly replace by_qval = min(by_qval, 1)
    quietly sort _orig
    quietly drop _orig _rank _raw
end

*-------------------------------------------------------------------------------
* PROGRAM 2: BKY(2006) sharpened two-stage -- Anderson (2008)
* (non-interactive rewrite of Anderson's published .do file)
*-------------------------------------------------------------------------------
capture program drop bky_sharpened_q
program define bky_sharpened_q
    args pvalvar
    quietly count if `pvalvar' < .
    local totalpvals = r(N)
    quietly gen long _orig_order = _n
    quietly sort `pvalvar'
    quietly gen long _rank = _n if `pvalvar' < .
    quietly gen double bky06_qval = 1 if `pvalvar' < .
    local qval = 1
    while `qval' > 0 {
        local qval_adj = `qval'/(1+`qval')
        quietly gen double _f1 = `qval_adj'*_rank/`totalpvals'
        quietly gen byte   _r1 = (_f1 >= `pvalvar') if `pvalvar' < .
        quietly gen long   _rr1 = _r1*_rank
        quietly egen long  _tot1 = max(_rr1)
        local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-_tot1[1]))
        quietly gen double _f2 = `qval_2st'*_rank/`totalpvals'
        quietly gen byte   _r2 = (_f2 >= `pvalvar') if `pvalvar' < .
        quietly gen long   _rr2 = _r2*_rank
        quietly egen long  _tot2 = max(_rr2)
        quietly replace bky06_qval = `qval' if _rank <= _tot2 & _rank < .
        quietly drop _f1 _r1 _rr1 _tot1 _f2 _r2 _rr2 _tot2
        local qval = `qval' - .001
    }
    quietly sort _orig_order
    quietly drop _orig_order _rank
end

*-------------------------------------------------------------------------------
* HELPER: run both methods on the current data's `pval` and list side by side
*-------------------------------------------------------------------------------
capture program drop run_both
program define run_both
    preserve
        by2001_q pval
        bky_sharpened_q pval
        list outcome pval by_qval bky06_qval, sep(0) noobs
    restore
end


*-------------------------------------------------------------------------------
* TABLE 1 / APPENDIX A.2  (family of 8)
* >>> REPLACE the . placeholders with verified raw p-values, in table order <<<
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"main_workers"      0.058
"ag_labor"          0.636
"cultivators"       0.522
"nonag"             0.009
"nonag_hh"          0.402
"nonag_other"       0.014
"firm_owners"       0.221
"firms_emp_women"   0.029
end
display _newline(2) "==== TABLE 1 / A.2 ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 3  (levels)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"col1_men_ag"    0.318
"col2_fem_ag" 0.670
"col3_men_nonag"    0.115
"col4_fem_nonag" 0.046
end
display _newline(2) "==== TABLE 3 ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 4  (family of 2: triple-interaction row only)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"col1_fem_nonag"    0.034
"col2_firms_empwom" 0.068
end
display _newline(2) "==== TABLE 4 ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 5 -- SC/ST interactions (family of 8)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"scst_main_workers"   0.248
"scst_ag_labor"       0.523
"scst_cultivators"    0.033
"scst_nonag"          0.395
"scst_nonag_hh"       0.591
"scst_nonag_other"    0.324
"scst_firm_owners"    0.049
"scst_firms_empwom"   0.643
end
display _newline(2) "==== TABLE 5 SC/ST ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 5 -- UC interactions (family of 8)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"uc_main_workers"     0.689
"uc_ag_labor"         0.615
"uc_cultivators"      0.577
"uc_nonag"            0.320
"uc_nonag_hh"         0.010
"uc_nonag_other"      0.004
"uc_firm_owners"      0.056
"uc_firms_empwom"     0.152
end
display _newline(2) "==== TABLE 5 UC ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 6 -- Purdah (family of 8)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"purdah_main_workers" 0.146
"purdah_ag_labor"    0.005
"purdah_cultivators"  0.001
"purdah_nonag"        0.338
"purdah_nonag_hh"     0.946
"purdah_nonag_other"  0.967
"purdah_firm_owners"  0.008
"purdah_firms_empwom" 0.936
end
display _newline(2) "==== TABLE 6 Purdah ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 7 -- Soil/clay (family of 8)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"soil_main_workers"   0.885
"soil_ag_labor"       0.232
"soil_cultivators"    0.560
"soil_nonag"          0.378
"soil_nonag_hh"       0.252
"soil_nonag_other"    0.073
"soil_firm_owners"    0.042
"soil_firms_empwom"   0.275
end
display _newline(2) "==== TABLE 7 Soil ===="
run_both


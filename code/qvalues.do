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
"main_workers"      0.143
"ag_labor"          0.799
"cultivators"       0.589
"nonag"             0.008
"nonag_hh"          0.167
"nonag_other"       0.007
"firm_owners"       0.351
"firms_emp_women"   0.082
end
display _newline(2) "==== TABLE 1 / A.2 ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 3  (levels)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"col1_men_ag"    0.009
"col2_fem_ag" 0.205
"col3_men_nonag"    0.897
"col4_fem_nonag" 0.165
end
display _newline(2) "==== TABLE 3 ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 4  (family of 2: triple-interaction row only)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"col1_fem_nonag"    0.043
"col2_firms_empwom" 0.099
end
display _newline(2) "==== TABLE 4 ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 5 -- SC/ST interactions (family of 8)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"scst_main_workers"   0.223
"scst_ag_labor"       0.482
"scst_cultivators"    0.032
"scst_nonag"          0.397
"scst_nonag_hh"       0.682
"scst_nonag_other"    0.415
"scst_firm_owners"    0.045
"scst_firms_empwom"   0.670
end
display _newline(2) "==== TABLE 5 SC/ST ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 5 -- UC interactions (family of 8)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"uc_main_workers"     0.824
"uc_ag_labor"         0.677
"uc_cultivators"      0.577
"uc_nonag"            0.233
"uc_nonag_hh"         0.008
"uc_nonag_other"      0.011
"uc_firm_owners"      0.041
"uc_firms_empwom"     0.115
end
display _newline(2) "==== TABLE 5 UC ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 6 -- Purdah (family of 8)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"purdah_main_workers" 0.011
"purdah_ag_labor"    0.003
"purdah_cultivators"  0.000
"purdah_nonag"        0.159
"purdah_nonag_hh"     0.193
"purdah_nonag_other"  0.036
"purdah_firm_owners"  0.025
"purdah_firms_empwom" 0.729
end
display _newline(2) "==== TABLE 6 Purdah ===="
run_both

*-------------------------------------------------------------------------------
* TABLE 7 -- Soil/clay (family of 8)
*-------------------------------------------------------------------------------
clear
input str25 outcome double pval
"soil_main_workers"   0.857
"soil_ag_labor"       0.259
"soil_cultivators"    0.531
"soil_nonag"          0.360
"soil_nonag_hh"       0.245
"soil_nonag_other"    0.075
"soil_firm_owners"    0.037
"soil_firms_empwom"   0.278
end
display _newline(2) "==== TABLE 7 Soil ===="
run_both


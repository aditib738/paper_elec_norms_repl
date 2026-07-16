/* Note: to run this do file first download subdistrict polygon shapefiles */
/* from devdatalab.org */

/* soil analysis subdistrict level file */
use $tmp/soil_analysis, clear

/* keep only what we need */
keep pc11_state_id pc11_district_id pc11_subdistrict_id clay
duplicates drop

/* compress save */
compress
save $tmp/soil, replace

/* bring in gps coords */
shp2dta using "~/data/pc11-subdistrict.shp", database("$tmp/base_data") coordinates("$tmp/coord") genid(geoid) replace

/* merge coordinates with dataset with vote share change */
use $tmp/base_data, clear
ren pc11_s_id pc11_state_id
ren pc11_d_id pc11_district_id
ren pc11_sd_id pc11_subdistrict_id
destring pc11*id, replace
merge m:1 pc11_state_id pc11_district_id pc11_subdistrict_id using $tmp/soil, keep(master match) nogen

/* make map */
set scheme white_tableau
colorpalette viridis, n(5) nograph 
local colors `r(p)'

format clay %9.2f
spmap clay using $tmp/coord, id(geoid) fcolor("`colors'") ///
    clnumber(10) ///
    ocolor(black ..) osize(vvthin ..) ///
    ndocolor(gray ..) ndsize(vvthin ..) 
graph export $out/map_soil_sd.pdf, replace

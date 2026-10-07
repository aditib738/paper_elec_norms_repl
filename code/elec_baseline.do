/* creates a map of electricity access at baseline */
use ~/data/raw_elec_new, clear

/* keep only baseline */
keep if period == 1

/* merge with shrid */
merge 1:m shrid2 using ~/data/pc11r_shrid_key, keep(match) nogen

/* collapse by subdistrict */
collapse (mean) nl, by(pc11_state_id pc11_district_id pc11_subdistrict_id)

/* rename */
ren pc11_state_id pc11_s_id
ren pc11_district_id pc11_d_id
ren pc11_subdistrict_id pc11_sd_id

/* save as working dataset */
compress
save $tmp/working_nl, replace

/* bring in gps coords */
shp2dta using ~/data/pc11-subdistrict.shp, database("$tmp/base_data") coordinates("$tmp/coord") genid(geoid) replace

use $tmp/base_data, clear

/* merge with working data */
merge 1:1 pc11_s_id pc11_d_id pc11_sd_id using $tmp/working, keep(match) nogen

/* make maps */
set scheme white_tableau
format nl %9.2fc
colorpalette cividis, n(10) nograph 
local colors `r(p)'
spmap nl using $tmp/coord, id(geoid) fcolor("`colors'") ///
    ocolor(white ..) osize(vvthin ..) ///
    ndocolor(gray ..) ndsize(vvthin ..) clnumber(10) ///
    title("Mean Night Luminosity (2001)", size(medsmall)) legend(off)
graph export $out/nl_share.png, replace


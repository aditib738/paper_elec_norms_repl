/* Note: to run this do file first download subdistrict polygon shapefiles */
/* from devdatalab.org */

/* bring in gps coords */
shp2dta using ~/data/pc11-subdistrict.shp, database("$tmp/base_data") coordinates("$tmp/coord") genid(geoid) replace

use $tmp/base_data, clear

/* merge with working data */
merge 1:1 pc11_s_id pc11_d_id pc11_sd_id using $tmp/working_nl, keep(match) nogen

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


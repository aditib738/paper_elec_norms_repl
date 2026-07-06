/* this do file creates a map of treated/control districts */
/* get coordinates */
/* convert shape file to dta format */
shp2dta using "$tmp/pc11-district.shp", database("$tmp/base_data") coordinates("$tmp/coord") genid(geoid) replace

/* merge coordinates with dataset with vote share change */
use $tmp/base_data, clear
ren pc11_s_id pc11_state_id
ren pc11_d_id pc11_district_id
destring pc11_state_id pc11_district_id, replace
merge m:1 pc11_state_id pc11_district_id using $tmp/districts_treat, keep(master match) nogen

/* replace missings */
replace type = . if type == 99
replace type = 9 if type == 12

/* make map */
set scheme white_tableau
colorpalette cividis, n(4) nograph reverse
local colors `r(p)'

spmap type using $tmp/coord, id(geoid) fcolor("`colors'") ///
    clmethod(unique) legend(pos(2) row(4) ring(1) ///
    label(3 "10th plan") label(4 "11th plan") label(2 "Both 10th and 11th") ///
    label(5 "Not covered by RGGVY") size(small)) ///
    ocolor(black ..) osize(vvthin ..) ///
    ndocolor(gray ..) ndsize(vvthin ..) 
graph export $out/map.png, replace

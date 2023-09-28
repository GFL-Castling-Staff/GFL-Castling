rem use lookup table to only show specific depth levels
convert _big_grey_height.png map_view_water_lookup.png -clut -resize 3072x3072 _map_water.png

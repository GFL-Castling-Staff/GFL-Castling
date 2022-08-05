rem blur woods to make it spread
convert _grey_woods.png -blur 0x20 _map_woods.png
convert _map_woods.png map_view_woods_lookup.png -clut -negate _map_woods2.png

rem use woods area as mask for woods pattern
convert map_view_tile_white.png map_view_woods_pattern.png _map_woods2.png -composite _map_composed_woods.png

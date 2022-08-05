rem isolines
rem water
composite -compose Multiply _map_isoline.png _map_water.png _map_composed1.png

rem map view decoration
composite -compose DstOver _map_composed1.png _rwr_map_view_decoration.png _map_composed2.png

rem woods
composite -compose Multiply _map_composed2.png _map_composed_woods.png _map_composed3.png

rem asphalt
convert _rwr_alpha_asphalt.png -alpha extract -depth 8 _map_asphalt_mask.png 
convert _map_composed3.png map_view_tile_asphalt.png _map_asphalt_mask.png -composite _map_composed4.png

rem road
convert _rwr_alpha_road.png -alpha extract -depth 8 _map_road_mask.png 
convert _map_composed4.png map_view_tile_road.png _map_road_mask.png -composite _map_composed5.png

rem map view decoration
composite -compose DstOver _map_composed5.png _rwr_map_view_bases.png _map_composed6.png

rem objects
composite -compose DstOver _map_composed6.png _grey_objects.png map.png

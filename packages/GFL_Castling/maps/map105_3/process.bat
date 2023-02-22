rem you need ImageMagick convert.exe

rem splat files: extract alpha channel, 8-bit greyscale, apply some gaussian blur
convert.exe _rwr_alpha_grass.png -alpha extract -depth 8 -gaussian-blur 4x4 terrain5_alpha_grass.png
convert.exe _rwr_alpha_sand.png -alpha extract -depth 8 -gaussian-blur 4x4 terrain5_alpha_sand.png
convert.exe _rwr_alpha_asphalt.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_asphalt.png
convert.exe _rwr_alpha_road.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_road.png

convert.exe _rwr_alpha_dirt_effect.png -alpha extract -depth 8 effect_alpha_dirt.png

rem heightmap to 513x513, 8-bit greyscale
convert.exe _rwr_height.png -type Grayscale -resize 513x513 -depth 8 terrain5_heightmap.png

rem map_view to 512x512
convert.exe _rwr_map_view.png -resize 512x512 -modulate 100,0 map.png
rem you need ImageMagick convert.exe

rem splat files: extract alpha channel, 8-bit greyscale, apply some gaussian blur
convert.exe _rwr_alpha_grass.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_grass.png
convert.exe _rwr_alpha_sand.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_sand.png
convert.exe _rwr_alpha_rocky_mountain.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_rocky_mountain.png
convert.exe _rwr_alpha_road.png -alpha extract -depth 8 -gaussian-blur 3x3 terrain5_alpha_road.png




rem heightmap to 513x513, 8-bit greyscale
convert.exe _rwr_height.png -type Grayscale -resize 1025x1025 -depth 8 terrain5_heightmap.png

rem map_view to 512x512
rem convert.exe _rwr_map_view.png -resize 512x512 -modulate 100,0 map.png

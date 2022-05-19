rem you need ImageMagick convert.exe

rem splat files: extract alpha channel, 8-bit greyscale, apply some gaussian blur
convert.exe _rwr_alpha_wheat.png -alpha extract -depth 8 -gaussian-blur 6x6 terrain5_alpha_wheat.png
convert.exe _rwr_alpha_grass.png -alpha extract -depth 8 -gaussian-blur 4x4 terrain5_alpha_grass.png
convert.exe _rwr_alpha_dirtroad.png -alpha extract -depth 8 -gaussian-blur 1x1 effect_alpha_dirtroad.png
convert.exe _rwr_alpha_asphalt.png -alpha extract -depth 8 terrain5_alpha_asphalt.png
convert.exe _rwr_alpha_muddyroad.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_muddyroad.png


rem heightmap to 513x513, 8-bit greyscale
convert.exe _rwr_height.png -type Grayscale -resize 1025x1025 -depth 8 terrain5_heightmap.png

rem map_view to 512x512
convert.exe _rwr_map_view.png -resize 512x512 -modulate 100,0 map.png

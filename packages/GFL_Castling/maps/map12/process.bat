	rem you need ImageMagick convert.exe and composite.exe

rem splat files: extract alpha channel, 8-bit greyscale, apply some gaussian blur
rem convert.exe _rwr_alpha_grass.png -alpha extract -depth 8 -gaussian-blur 3x3 terrain5_alpha_grass.png
rem convert.exe _rwr_alpha_sand.png -alpha extract -depth 8 -gaussian-blur 3x3 terrain5_alpha_sand.png
rem convert.exe _rwr_alpha_snow.png -alpha extract -depth 8 -gaussian-blur 3x3 terrain5_alpha_snow.png
rem convert.exe _rwr_alpha_road.png -alpha extract -depth 8 -gaussian-blur 3x3 terrain5_alpha_road.png
rem convert.exe _rwr_alpha_grass.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_grass.png
convert.exe _rwr_alpha_sand.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_sand.png

rem snow layer is special to allow easy cutting with black elements on otherwise white layer:
rem - extract red channel for black-white cutting
rem - extract alpha channel for the usual geometry based cutting
rem - combine these layers
convert.exe _rwr_alpha_snow.png -channel R -separate _rwr_alpha_snow_r.png
convert.exe _rwr_alpha_snow_r.png -gaussian-blur 3x3 _rwr_alpha_snow_r.png

rem blur alpha or not?
convert.exe _rwr_alpha_snow.png -alpha extract -depth 8 -gaussian-blur 6x6 _rwr_alpha_snow_a.png

composite.exe _rwr_alpha_snow_r.png -compose Multiply _rwr_alpha_snow_a.png terrain5_alpha_snow.png

rem there's also now "top snow" effect layer with subtractive surface effect, apply same stuff for it 
convert.exe _rwr_alpha_topsnow.png -channel R -separate _rwr_alpha_topsnow_r.png
convert.exe _rwr_alpha_topsnow_r.png -gaussian-blur 1x1 _rwr_alpha_topsnow_r.png
convert.exe _rwr_alpha_topsnow.png -alpha extract -depth 8 -gaussian-blur 6x6 _rwr_alpha_topsnow_a.png
composite.exe _rwr_alpha_topsnow_r.png -compose Multiply _rwr_alpha_topsnow_a.png terrain5_alpha_topsnow.png

convert.exe _rwr_alpha_snowroad.png -alpha extract -depth 8 -gaussian-blur 2x2 terrain5_alpha_snowroad.png

rem heightmap to 1025x1025, 8-bit greyscale
convert.exe _rwr_height.png -type Grayscale -resize 1025x1025 -depth 8 terrain5_heightmap.png

rem map_view to 512x512
convert.exe _rwr_map_view.png -resize 512x512 -modulate 100,0 map.png

process_post.bat
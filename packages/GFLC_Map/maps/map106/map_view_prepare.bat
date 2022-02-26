rem heightmap to 8-bit greyscale
convert.exe _rwr_height.png -type Grayscale -resize 4096x4096 -depth 8 -set colorspace RGB _big_grey_height.png

rem convert.exe _rwr_map_view_woods.png -type Grayscale -depth 8 -set colorspace RGB _grey_woods.png
rem convert.exe _rwr_map_view_woods.png -modulate 100,0 _grey_woods.png
convert.exe _rwr_map_view_woods.png -alpha extract -depth 8 _grey_woods.png

convert.exe _rwr_map_view.png -modulate 100,0 _grey_objects.png

rem you need ImageMagick convert.exe	

rem 1-pass terrain optimization: merge splat files to one, 4 is max

convert terrain5_alpha_sand.png -colorspace RGB terrain5_alpha_grass.png -colorspace RGB terrain5_alpha_asphalt.png -colorspace RGB terrain5_alpha_road.png -colorspace RGB -channel RGBA -combine terrain5_combined_alpha.png

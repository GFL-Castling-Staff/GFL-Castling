rem you need ImageMagick convert.exe	

rem 1-pass terrain optimization: merge splat files to one, 4 is max

convert effect_none.png -colorspace RGB effect_none.png -colorspace RGB terrain5_alpha_topsnow.png -colorspace RGB effect_none_a.png -colorspace RGB -channel RGBA -combine -colorspace RGB PNG32:effect_combined_alpha.png

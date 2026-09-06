"""Build P22's authored vector UI glyphs and matching transparent game textures.

No source bitmap is modified. SVGs are retained beside the PNGs for editing.
Requires Pillow; run from any working directory on Windows.
"""
from pathlib import Path
import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw, ImageFont

DEST = Path(__file__).resolve().parents[1] / "packages/GFL_Castling/materials"
FONT = Path("C:/Windows/Fonts/arialbd.ttf")
SCALE = 4


class Icon:
    def __init__(self, width, height):
        self.size = width, height
        self.svg = ET.Element("svg", xmlns="http://www.w3.org/2000/svg",
                              viewBox=f"0 0 {width} {height}")
        self.image = Image.new("RGBA", (width*SCALE, height*SCALE))
        self.draw = ImageDraw.Draw(self.image)

    def polygon(self, points, fill):
        ET.SubElement(self.svg, "polygon", points=" ".join(f"{x},{y}" for x,y in points), fill=fill)
        self.draw.polygon([(x*SCALE,y*SCALE) for x,y in points], fill=fill)

    def rect(self, x, y, width, height, fill):
        ET.SubElement(self.svg, "rect", x=str(x), y=str(y), width=str(width), height=str(height), fill=fill)
        self.draw.rectangle((x*SCALE,y*SCALE,(x+width)*SCALE,(y+height)*SCALE), fill=fill)

    def text(self, x, y, value, size, fill):
        ET.SubElement(self.svg, "text", x=str(x), y=str(y), fill=fill,
                      attrib={"font-family":"Arial", "font-weight":"bold", "font-size":str(size),
                              "text-anchor":"middle", "dominant-baseline":"central"}).text=value
        self.draw.text((x*SCALE,y*SCALE), value,
                       font=ImageFont.truetype(str(FONT), size*SCALE), fill=fill, anchor="mm")

    def save(self, name):
        ET.indent(self.svg)
        ET.ElementTree(self.svg).write(DEST/f"{name}.svg", encoding="utf-8", xml_declaration=True)
        # Half-size and 64 colours keep these small without losing antialiasing.
        # Export explicit RGBA (PNG type 6), like alert_marker.png. Indexed PNG
        # transparency looked correct in previews but showed a black quad in RWR.
        size = tuple(value // 2 for value in self.size)
        texture = self.image.resize(size, Image.Resampling.LANCZOS)
        texture = texture.quantize(colors=64, method=Image.Quantize.FASTOCTREE,
                                   dither=Image.Dither.NONE)
        texture = texture.convert("RGBA")
        texture.save(DEST/f"{name}.png", optimize=True, compress_level=9)


def main():
    # A grenade silhouette with two literal plus signs. No warning starburst.
    icon = Icon(256,128)
    white, green, dark = "#F2FFF5", "#8FFFAD", "#143826"
    icon.polygon([(22,42),(39,32),(74,32),(91,45),(96,93),(79,113),(36,113),(18,94)], dark)
    icon.polygon([(27,45),(42,37),(71,37),(85,48),(90,90),(75,106),(40,106),(24,91)], white)
    icon.rect(42,20,28,13,white)
    icon.polygon([(48,13),(84,13),(99,29),(93,35),(80,23),(48,23)],white)
    icon.rect(26,64,62,6,dark)
    icon.rect(27,86,61,6,dark)
    icon.rect(52,39,7,64,dark)
    for x in (134,202):
        icon.rect(x-23,64-7,46,14,green)
        icon.rect(x-7,64-23,14,46,green)
    icon.save("p22_grenade_plus")

    # Keep the gold shield and its dark interior; only the exterior is transparent.
    icon = Icon(256,256)
    icon.polygon([(34,36),(222,36),(240,54),(240,179),(128,235),(16,179),(16,54)],"#F29733")
    icon.polygon([(39,44),(217,44),(232,59),(232,174),(128,225),(24,174),(24,59)],"#17222B")
    for side in (0,1):
        for row in range(3):
            y=64+row*16
            pts=[(35,y),(69,y),(78,y+8),(35,y+8)]
            if side:
                pts=[(256-x,y) for x,y in pts]
            icon.polygon(pts,"#F29733")
    icon.text(128,125,"G&K",62,"#FFF5DF")
    icon.rect(49,162,158,4,"#F29733")
    icon.text(128,186,"GRIFFIN",25,"#F29733")
    icon.save("p22_griffin_beacon")


if __name__ == "__main__":
    main()

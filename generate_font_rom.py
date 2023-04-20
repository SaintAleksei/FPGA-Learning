import sys
from PIL import Image, ImageFont, ImageDraw

def extract_glyph_bitmap(font_path, glyph, x_size, y_size):
    font = ImageFont.truetype(font_path, y_size)
    img = Image.new('1', (x_size, y_size), 0)
    draw = ImageDraw.Draw(img)
    draw.text((0, 0), glyph, font=font, fill=1)
    img = img.crop(img.getbbox())

    width, height = img.size
    pixel_matrix = [[img.getpixel((x, y)) for x in range(width)] for y in range(height)]

    return pixel_matrix

def bitmap_to_verilog(matrix):
    lines = []
    for row in matrix:
        line = "5'b" + "".join(str(bit) for bit in row) + ";"
        lines.append(line)
    return lines

def main(font_path, x_size, y_size):
    output_file = "font_rom.v"
    with open(output_file, "w") as f:
        f.write("module font_rom (\n  input wire [4:0] address,\n  input wire [4:0] row,\n  output reg [4:0] data\n);\n\n")
        f.write("  reg [4:0] font [0:25][0:6];\n\n")

        f.write("  initial begin\n")
        for idx, char in enumerate("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):
            matrix = extract_glyph_bitmap(font_path, char, x_size, y_size)
            verilog_matrix = bitmap_to_verilog(matrix)
            for i, row in enumerate(verilog_matrix):
                f.write(f"    font[{x_size*idx+i}] = {row}\n")
        f.write("  end\n\n")

if __name__ == "__main__":
    font_path = sys.argv[1]
    matrix = extract_glyph_bitmap(font_path, 'A', 100, 100)
    for row in matrix:
      for pixel in row:
        if pixel == 1:
          print("#", end='')
        else:
          print(".", end='')
      print()

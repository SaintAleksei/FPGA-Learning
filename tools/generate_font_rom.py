#!/usr/bin/python3

import argparse
import re
import os
from PIL import Image, ImageFont, ImageDraw

printable = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'

def process_template(template_file, **subs):
  with open(template_file, 'r') as f:
    template = f.read()

  # Define variables to be used in the template
  name = 'John'
  current_year = 2023

  # Find and replace inline Python code
  pattern = r'\{\{([^}]+)\}\}'
  def evaluate_expression(match):
    expression = match.group(1).strip()
    result = eval(expression, subs)
    return str(result)

  instantiated_template = re.sub(pattern, evaluate_expression, template)
  return instantiated_template

def max_font_dimensions(font_path, font_size):
  font = ImageFont.truetype(font_path, font_size)

  max_width = 0
  max_height = 0

  for char_code in range(256):
    char = chr(char_code)
    if char in printable:
      bbox = font.getbbox(char)
      width  = bbox[2] - bbox[0]
      height = bbox[3] - bbox[1]

      max_width  = max(max_width, width)
      max_height = max(max_height, height)

  return max_width, max_height

def extract_glyph_bitmap(font_path, font_size, glyph, x_size, y_size):
  font = ImageFont.truetype(font_path, font_size)
  img = Image.new('1', (x_size, y_size), 0)
  draw = ImageDraw.Draw(img)
  
  draw.text((0, 0), glyph, font=font, fill=1)

  width, height = img.size
  pixel_matrix = [[img.getpixel((x, y)) for x in range(width)] for y in range(height)]

  return pixel_matrix

def bitmap_to_verilog(matrix):
  lines = []
  for row in matrix:
    line = str(len(row)) + "'b";
    for pixel in row:
      line = line + str(pixel)
    lines.append(line)
  return lines

def main(font_path, font_size, template_file):
  font_generation = ""
  x_size, y_size = max_font_dimensions(font_path, font_size)
  unprintable = [[1] * x_size] * y_size
  for char in range(256):
    matrix = unprintable
    if chr(char) in printable:
      matrix = extract_glyph_bitmap(font_path, font_size, chr(char), x_size, y_size)
    verilog_matrix = bitmap_to_verilog(matrix)
    for idx, line in enumerate(verilog_matrix):
      font_generation = font_generation + f'\tassign font[{idx}][{char}] = {line};\n'
    font_generation = font_generation + '\n'

  font_path_basename = os.path.basename(font_path)

  font_rom_name = 'font_' + font_path_basename.split('.')[0] + f'_{x_size}x{y_size}'
  font_rom_path = os.path.join('font', font_rom_name + '.v')

  font_rom_file = process_template(template_file, 
                                   FONT_NAME=font_rom_name,
                                   FONT_GENERATION=font_generation,
                                   FONT_WIDTH=x_size,
                                   FONT_HEIGHT=y_size)
  with open(font_rom_path, 'w') as f:
    f.write(font_rom_file)

if __name__ == "__main__":
  arg_parser = argparse.ArgumentParser(description="Python tool for generating verilog ROM with font from TTF/OTF files")
  arg_parser.add_argument("--font", type=str, required=True, help="file with font in TTF/OTF format")
  arg_parser.add_argument("--size", type=int, required=True, help="size of font in output verilog ROM")
  args = arg_parser.parse_args()

  main(args.font, args.size, 'font/font_rom_template.v')

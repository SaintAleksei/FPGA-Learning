#!/bin/bash

# Set the list of extensions to keep
extensions=(c v sh qpf qsf md)

# Construct a list of file patterns that match the extensions
patterns=$(printf " ! -name '*.%s'" "${extensions[@]}")

# Find and delete all files whose extensions do not match the list
eval "find . -type f \( $patterns \) -print0 | xargs -0 rm -f"

# Find and remove all empty directories
find . -type d -empty -delete

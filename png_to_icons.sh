#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 INPUT.png [THRESHOLD]"
  echo "Example: $0 cube.png 70"
  exit 1
fi

input="$1"
threshold="${2:-70}"

if [[ ! -f "$input" ]]; then
  echo "Error: input file not found: $input" >&2
  exit 1
fi

for command in convert potrace; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Error: required command not found: $command" >&2
    exit 1
  fi
done

filename="$(basename "$input")"
name="${filename%.*}"
directory="$(dirname "$input")"

pbm="$(mktemp --suffix=.pbm)"
trap 'rm -f "$pbm"' EXIT

black_svg="${directory}/${name}-black.svg"
white_svg="${directory}/${name}-white.svg"

echo "Converting: $input"
echo "Threshold:  ${threshold}%"

# Create a monochrome bitmap:
# black icon lines on a white background.
convert "$input" \
  -background white \
  -alpha background \
  -alpha off \
  -colorspace Gray \
  -threshold "${threshold}%" \
  "$pbm"

# Trace the black pixels into a real vector SVG.
potrace "$pbm" \
  --svg \
  --output "$black_svg"

# Create the white version by recoloring the traced vector.
cp "$black_svg" "$white_svg"

sed -i \
  -e 's/fill="#000000"/fill="#ffffff"/g' \
  -e 's/fill="black"/fill="#ffffff"/g' \
  "$white_svg"

echo
echo "Created:"
echo "  $black_svg"
echo "  $white_svg"
echo
du -h "$black_svg" "$white_svg"


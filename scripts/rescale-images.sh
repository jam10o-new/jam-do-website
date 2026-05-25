#!/bin/bash
# Rescale and compress images in images/ directory for web use.
# Usage: ./scripts/rescale-images.sh
# Requires: ImageMagick (magick)
#
# Scales images to max 1200px wide, compresses JPEG to quality 75,
# strips EXIF metadata, and produces progressive JPEGs.

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
IMAGES_DIR="$SCRIPT_DIR/../images"
MAX_WIDTH=1200
QUALITY=75

if ! command -v magick &>/dev/null && ! command -v convert &>/dev/null; then
    echo "Error: ImageMagick is required. Install with: sudo apt install imagemagick" >&2
    exit 1
fi

echo "Rescaling images in $IMAGES_DIR ..."
echo ""

count=0
for img in "$IMAGES_DIR"/*.{jpg,JPG,jpeg,JPEG}; do
    [ -f "$img" ] || continue

    original_size=$(stat -c%s "$img" 2>/dev/null || stat -f%z "$img" 2>/dev/null)

    # Use magick if available, fall back to convert
    if command -v magick &>/dev/null; then
        magick "$img" \
            -resize "${MAX_WIDTH}x${MAX_WIDTH}>" \
            -strip \
            -interlace Plane \
            -quality "$QUALITY" \
            "$img"
    else
        convert "$img" \
            -resize "${MAX_WIDTH}x${MAX_WIDTH}>" \
            -strip \
            -interlace Plane \
            -quality "$QUALITY" \
            "$img"
    fi

    new_size=$(stat -c%s "$img" 2>/dev/null || stat -f%z "$img" 2>/dev/null)
    echo "  $(basename "$img"): $(numfmt --to=iec "$original_size") -> $(numfmt --to=iec "$new_size")"
    count=$((count + 1))
done

echo ""
echo "Done. Rescaled $count images."
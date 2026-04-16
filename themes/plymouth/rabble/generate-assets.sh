#!/usr/bin/env bash
# themes/plymouth/rabble/generate-assets.sh
# =============================================================================
# Generate PNG assets for the RaBbLE Plymouth theme.
# Requires: imagemagick (convert)
# =============================================================================
set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="${THEME_DIR}/assets"
mkdir -p "${ASSETS}/spinner"

if ! command -v convert &>/dev/null; then
    echo "ERROR: imagemagick 'convert' required. Install: sudo dnf install imagemagick"
    exit 1
fi

echo "Generating RaBbLE Plymouth assets..."

# ── Background ────────────────────────────────────────────────────────────────
echo "  bg.png..."
convert -size 1920x1080 \
    gradient:"#0d0f1a-#12132a" \
    "${ASSETS}/bg.png"

# ── Logo — RaBbLE wordmark rendered as image ──────────────────────────────────
echo "  logo.png..."
convert -size 512x256 xc:"#0d0f1a00" \
    -font "DejaVu-Sans-Bold" \
    -pointsize 96 \
    -fill "#7c6fe0" \
    -gravity Center \
    -annotate 0 "RaBbLE" \
    "${ASSETS}/logo.png"

# ── Spinner frames — simple arc animation ─────────────────────────────────────
echo "  spinner frames (24 frames)..."
FRAMES=24
for (( i=0; i<FRAMES; i++ )); do
    angle=$(( i * 360 / FRAMES ))
    frame_file="${ASSETS}/spinner/frame-$(printf '%02d' "${i}").png"

    # Draw a progress arc on transparent background
    convert -size 64x64 xc:none \
        -stroke "#7c6fe0" \
        -strokewidth 4 \
        -fill none \
        -draw "arc 6,6 58,58 ${angle},$(( (angle + 240) % 360 ))" \
        -stroke "#4ecdc4" \
        -strokewidth 2 \
        -draw "arc 8,8 56,56 $(( (angle + 180) % 360 )),$(( (angle + 300) % 360 ))" \
        "${frame_file}"
done

# ── Dialog background (password prompt) ───────────────────────────────────────
echo "  dialog.png..."
convert -size 400x60 xc:"#1a1b2edd" \
    -fill none \
    -stroke "#7c6fe088" \
    -strokewidth 1 \
    -draw "roundrectangle 0,0 399,59 8,8" \
    "${ASSETS}/dialog.png"

echo ""
echo "Plymouth assets generated in: ${ASSETS}"
echo "Replace logo.png with your own SVG-exported PNG for best quality."
echo "Next: run the ansible boot role (bootstrap.sh → Boot Layer → Plymouth)"

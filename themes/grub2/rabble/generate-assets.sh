#!/usr/bin/env bash
# themes/grub2/rabble/generate-assets.sh
# =============================================================================
# Generate the PNG assets for the RaBbLE Grub2 theme.
# Requires: imagemagick (convert), optionally python3 + pillow for gradient.
# Run once after cloning, or whenever you change the palette.
# =============================================================================
set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Check deps ────────────────────────────────────────────────────────────────
if ! command -v convert &>/dev/null; then
    echo "ERROR: imagemagick 'convert' not found. Install: sudo dnf install imagemagick"
    exit 1
fi

echo "Generating RaBbLE Grub2 theme assets..."
cd "${THEME_DIR}"

# ── Background — dark gradient ────────────────────────────────────────────────
echo "  background.png (3840×2400)..."
convert -size 3840x2400 \
    gradient:"#0d0f1a-#12132a" \
    -modulate 100,100,100 \
    background.png

# ── Top accent line — violet gradient ─────────────────────────────────────────
echo "  top_accent.png..."
convert -size 3840x3 \
    gradient:"#7c6fe0-#4ecdc4" \
    top_accent.png

# ── Selected item background ──────────────────────────────────────────────────
echo "  select_bkg_*.png (9-slice)..."
# Corner (1×1)
convert -size 1x1 xc:"#1a1b2e" select_bkg_c.png
# Center fill
convert -size 1x1 xc:"#1a1b2e" select_bkg_f.png
# Edge tiles
convert -size 1x1 xc:"#7c6fe033" select_bkg_e.png
# Full tile (simple single image approach for grub compatibility)
convert -size 800x54 \
    xc:"#1a1b2e" \
    -fill none \
    -stroke "#7c6fe066" \
    -strokewidth 1 \
    -draw "roundrectangle 0,0 799,53 8,8" \
    select_bkg_n.png

# ── Icon placeholders (replace with real icons from icon theme) ───────────────
mkdir -p icons

echo "  icons/fedora.png..."
convert -size 48x48 xc:"#0d0f1a" \
    -fill "#7c6fe0" \
    -draw "circle 24,24 24,4" \
    icons/fedora.png

echo "  icons/windows.png..."
convert -size 48x48 xc:"#0d0f1a" \
    -fill "#4ecdc4" \
    -draw "rectangle 4,4 22,22" \
    -draw "rectangle 26,4 44,22" \
    -draw "rectangle 4,26 22,44" \
    -draw "rectangle 26,26 44,44" \
    icons/windows.png

echo "  icons/linux.png..."
convert -size 48x48 xc:"#0d0f1a" \
    -fill "#e8e6f0" \
    -draw "circle 24,24 24,6" \
    icons/linux.png

echo ""
echo "Assets generated in: ${THEME_DIR}"
echo "NOTE: Replace icons/ with proper icons from your system icon theme for best results."
echo "Suggested source: /usr/share/icons/hicolor/48x48/apps/"

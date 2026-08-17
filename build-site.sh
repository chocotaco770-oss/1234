#!/usr/bin/env bash
#
# Inlines docs/screenshots/*.png into docs/index.html as base64 data URIs so
# the portal is fully self-contained (works on GitHub Pages, file://, anywhere).
#
# Run this after refreshing the screenshots:
#   1. mvn test                          (regenerates target/screenshots/*.png)
#   2. cp target/screenshots/*.png docs/screenshots/
#   3. ./build-site.sh
#
set -euo pipefail
cd "$(dirname "$0")"

html="docs/index.html"
start_marker="// __SCREENSHOT_DATA_START__"
end_marker="// __SCREENSHOT_DATA_END__"

pngs=(docs/screenshots/*.png)
if [ ! -e "${pngs[0]}" ]; then
  echo "No screenshots found in docs/screenshots/. Run 'mvn test' first." >&2
  exit 1
fi

# Build the JavaScript data map: { "Login.png": "data:image/png;base64,...", ... }
map="var SCREENSHOT_DATA = {"
first=1
for f in "${pngs[@]}"; do
  name="$(basename "$f")"
  b64="$(base64 -w0 "$f")"
  if [ "$first" = 1 ]; then first=0; else map="$map,"; fi
  map="$map"$'\n'"  \"$name\": \"data:image/png;base64,$b64\""
done
map="$map"$'\n'"};"

awk -v start="$start_marker" -v end="$end_marker" -v map="$map" '
  $0 ~ start { print; print map; skip=1; next }
  $0 ~ end   { print; skip=0; next }
  skip { next }
  { print }
' "$html" > "$html.tmp" && mv "$html.tmp" "$html"

echo "Inlined ${#pngs[@]} screenshots into $html ($(du -h "$html" | cut -f1))."

#!/usr/bin/env bash
set -euo pipefail

# One-shot release script: analyze, build web, sanity-check output, and (optionally) deploy to Vercel.
# Usage:
#   tool/release_web.sh [--renderer canvaskit|auto] [--deploy]

RENDERER="canvaskit"
DEPLOY=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --renderer)
      RENDERER="$2"; shift 2;;
    --deploy)
      DEPLOY=true; shift;;
    *) echo "Unknown arg: $1"; exit 2;;
  esac
done

echo "[1/4] flutter --version (informative)"
flutter --version || true

echo "[2/4] flutter analyze"
flutter pub get
flutter analyze || { echo "Analyzer found issues. Fix before releasing."; exit 1; }

echo "[3/4] flutter build web --release --web-renderer $RENDERER --pwa-strategy offline-first"
flutter build web --release --web-renderer "$RENDERER" --pwa-strategy offline-first

echo "[4/4] Sanity-check build artifacts"
[[ -f build/web/index.html ]] || { echo "Missing index.html in build/web"; exit 1; }
[[ -f build/web/flutter.js ]] || { echo "Missing flutter.js in build/web"; exit 1; }

if $DEPLOY; then
  command -v vercel >/dev/null 2>&1 || { echo "Vercel CLI not found. Run: npm i -g vercel"; exit 1; }
  echo "Deploying build/web to Vercel (production)..."
  vercel --prod build/web
fi

echo "Done. Output in build/web. Use --deploy to publish via Vercel CLI."


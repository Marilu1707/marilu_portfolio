#!/usr/bin/env bash
set -euo pipefail

# Vercel build script for Flutter Web
# - Installs Flutter in the build env
# - Fetches dependencies
# - Builds to build/web

export FLUTTER_VERSION="stable"  # or pin e.g. 3.24.4
export PATH="$HOME/.flutter/bin:$PATH"

echo "[1/6] Cloning Flutter ($FLUTTER_VERSION)"
git clone --depth 1 https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" "$HOME/.flutter"

echo "[2/6] Flutter version"
flutter --version
flutter config --enable-web

echo "[3/6] Pub get"
flutter pub get

echo "[4/6] Clean potentially problematic service worker (optional)"
rm -f web/flutter_service_worker.js || true

echo "[5/6] Build web"
RENDERER="${WEB_RENDERER:-html}"
flutter build web --release --web-renderer "$RENDERER"

echo "[6/6] Done: build/web (renderer=$RENDERER)"


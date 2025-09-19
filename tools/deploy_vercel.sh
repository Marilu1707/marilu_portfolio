#!/usr/bin/env bash
set -euo pipefail

# Wrapper: delega al script raíz si existe, o hace deploy directo.

if [ -x "./deploy_vercel.sh" ]; then
  exec ./deploy_vercel.sh "$@"
fi

command -v flutter >/dev/null 2>&1 || { echo "ERROR: Flutter no está en PATH"; exit 1; }
command -v vercel  >/dev/null 2>&1 || { echo "ERROR: Vercel CLI no está en PATH (npm i -g vercel)"; exit 1; }

RENDERER="${1:-canvaskit}"

if [ ! -f vercel.json ]; then
  cat > vercel.json <<'JSON'
{
  "version": 2,
  "public": true,
  "cleanUrls": true,
  "trailingSlash": false,
  "headers": [
    {
      "source": "/(.*)\\.(js|css|png|jpg|jpeg|gif|svg|webp|wasm|ico|ttf|woff|woff2)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    },
    {
      "source": "/flutter_service_worker.js",
      "headers": [
        { "key": "Cache-Control", "value": "no-cache" }
      ]
    }
  ],
  "routes": [
    { "handle": "filesystem" },
    { "src": "/.*", "dest": "/index.html" }
  ]
}
JSON
  echo "✔ Creado vercel.json con headers y SPA fallback"
fi

echo "🧹 flutter clean + pub get"
flutter clean
flutter pub get

echo "🛠️ flutter build web --web-renderer ${RENDERER}"
flutter build web --release --web-renderer "${RENDERER}" --base-href "/"

echo "🚀 vercel --prod build/web"
vercel --prod build/web

echo "✅ Deploy OK"


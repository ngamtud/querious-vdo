#!/usr/bin/env bash
# One-time setup: fonts + Playwright, Python venv, Kokoro voice model.
set -euo pipefail
cd "$(dirname "$0")"

command -v ffmpeg >/dev/null || { echo "ffmpeg not found. macOS: brew install ffmpeg"; exit 1; }
command -v node   >/dev/null || { echo "Node.js 20+ not found. macOS: brew install node"; exit 1; }

echo "→ npm packages (fonts, playwright)"
npm install --no-audit --no-fund --silent
# Download Chromium for Playwright unless one is already available (e.g. Claude's cloud workspace)
if ! node -e "require('fs').accessSync(require('playwright').chromium.executablePath())" 2>/dev/null; then
  npx playwright install chromium
fi

echo "→ Python packages (.venv)"
[ -d .venv ] || python3 -m venv .venv
.venv/bin/pip install -q -r requirements.txt

echo "→ Kokoro TTS model (Apache-2.0, ~100 MB, from the npm registry)"
if [ ! -f .cache/kokoro/kokoro-int8-en-v0_19/model.int8.onnx ]; then
  mkdir -p .cache/kokoro && cd .cache/kokoro
  npm pack n8n-nodes-ttsbro@0.1.6 --silent >/dev/null
  tar xzf n8n-nodes-ttsbro-0.1.6.tgz package/kokoro-int8-en-v0_19
  mv package/kokoro-int8-en-v0_19 . && rm -rf package n8n-nodes-ttsbro-0.1.6.tgz
  cd ../..
fi
if [ "${1:-}" = "--thai" ] || ls episodes/*/episode.json | xargs grep -l '"mms-tha"' >/dev/null 2>&1; then
  echo "→ Thai TTS model (Meta MMS-TTS, CC BY-NC 4.0: non-commercial only, ~110 MB, from GitHub)"
  if [ ! -f .cache/mms-tha/vits-mms-tha/model.onnx ]; then
    mkdir -p .cache/mms-tha && cd .cache/mms-tha
    curl -sSL -o m.tar.bz2 https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-mms-tha.tar.bz2
    tar xjf m.tar.bz2 && rm m.tar.bz2
    cd ../..
  fi
fi
echo "✓ setup done. Next: ./build.sh episodes/gapminder"

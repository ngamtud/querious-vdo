#!/usr/bin/env bash
# Build one episode end to end: voice → video → music + mix.
# usage: ./build.sh episodes/<name> [--skip-voice] [--skip-video]
set -euo pipefail
cd "$(dirname "$0")"
EP=${1:?usage: ./build.sh episodes/<name>}; shift || true
PY=python3; [ -x .venv/bin/python ] && PY=.venv/bin/python
SKIP_VOICE=0; SKIP_VIDEO=0
for a in "$@"; do case $a in --skip-voice) SKIP_VOICE=1;; --skip-video) SKIP_VIDEO=1;; esac; done

[ $SKIP_VOICE = 1 ] || { echo "→ voice-over"; $PY engine/tts.py "$EP"; }
[ $SKIP_VIDEO = 1 ] || { echo "→ video"; node engine/render.js "$EP"; }
echo "→ music + mix"
$PY engine/mix.py "$EP"

#!/usr/bin/env python3
"""Generate voice-over lines with Kokoro (offline, via sherpa-onnx).

usage: python3 engine/tts.py episodes/<name>
Reads episode.json -> voice + voiceover[], writes .cache/<name>/voice/<id>.wav
and prints each line's duration next to the time slot it has.
"""
import json, sys, os
import sherpa_onnx, soundfile as sf

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL = os.path.join(ROOT, '.cache', 'kokoro', 'kokoro-int8-en-v0_19')
# Kokoro v0.19 speaker ids
SPEAKERS = {'af': 0, 'af_bella': 1, 'af_nicole': 2, 'af_sarah': 3, 'af_sky': 4,
            'am_adam': 5, 'am_michael': 6, 'bf_emma': 7, 'bf_isabella': 8,
            'bm_george': 9, 'bm_lewis': 10}

ep_dir = os.path.abspath(sys.argv[1])
name = os.path.basename(ep_dir)
ep = json.load(open(os.path.join(ep_dir, 'episode.json')))
voice = ep['voice']
out_dir = os.path.join(ROOT, '.cache', name, 'voice')
os.makedirs(out_dir, exist_ok=True)

if not os.path.exists(os.path.join(MODEL, 'model.int8.onnx')):
    sys.exit('Kokoro model missing. Run ./setup.sh first.')

tts = sherpa_onnx.OfflineTts(sherpa_onnx.OfflineTtsConfig(
    model=sherpa_onnx.OfflineTtsModelConfig(
        kokoro=sherpa_onnx.OfflineTtsKokoroModelConfig(
            model=os.path.join(MODEL, 'model.int8.onnx'),
            voices=os.path.join(MODEL, 'voices.bin'),
            tokens=os.path.join(MODEL, 'tokens.txt'),
            data_dir=os.path.join(MODEL, 'espeak-ng-data')),
        num_threads=4)))

sid = SPEAKERS[voice.get('speaker', 'af_bella')]
lines = ep['voiceover']
for i, line in enumerate(lines):
    audio = tts.generate(line['text'], sid=sid, speed=voice.get('speed', 1.0))
    path = os.path.join(out_dir, f"{line['id']}.wav")
    sf.write(path, audio.samples, audio.sample_rate)
    dur = len(audio.samples) / audio.sample_rate
    nxt = lines[i + 1]['at'] if i + 1 < len(lines) else ep['duration']
    slot = nxt - line['at']
    flag = '' if dur <= slot - 0.15 else '  <-- too long for its slot'
    print(f"{line['id']:>4}  {dur:5.2f}s / slot {slot:5.2f}s{flag}")
print(f'voice → {out_dir}')

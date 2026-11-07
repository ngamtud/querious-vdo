#!/usr/bin/env python3
"""Generate voice-over lines offline via sherpa-onnx.

voice.engine "kokoro" (English, default) or "mms-tha" (Thai, Meta MMS-TTS, CC BY-NC 4.0: non-commercial use only).

usage: python3 engine/tts.py episodes/<name>
Reads episode.json -> voice + voiceover[], writes .cache/<name>/voice/<id>.wav
and prints each line's duration next to the time slot it has.
"""
import json, sys, os, subprocess
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

MMS_THA = os.path.join(ROOT, '.cache', 'mms-tha', 'vits-mms-tha')
engine = voice.get('engine', 'kokoro')
prep = lambda text: text
if engine == 'mms-tha':
    if not os.path.exists(os.path.join(MMS_THA, 'model.onnx')):
        sys.exit('Thai model missing. Run ./setup.sh --thai first.')
    tts = sherpa_onnx.OfflineTts(sherpa_onnx.OfflineTtsConfig(
        model=sherpa_onnx.OfflineTtsModelConfig(
            vits=sherpa_onnx.OfflineTtsVitsModelConfig(
                model=os.path.join(MMS_THA, 'model.onnx'),
                tokens=os.path.join(MMS_THA, 'tokens.txt')),
            num_threads=4)))
    sid = 0
    # the MMS vocabulary has no SARA AM (U+0E33): split it into NIKHAHIT + SARA AA.
    # Write numbers as Thai words; the model reads only Thai letters.
    prep = lambda text: text.replace('\u0e33', '\u0e4d\u0e32')
else:
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
    speed = voice.get('speed', 1.0)
    audio = tts.generate(prep(line['text']), sid=sid, speed=speed)
    dur = len(audio.samples) / audio.sample_rate
    nxt = lines[i + 1]['at'] if i + 1 < len(lines) else ep['duration']
    slot = nxt - line['at']
    path = os.path.join(out_dir, f"{line['id']}.wav")
    sf.write(path, audio.samples, audio.sample_rate)
    # voice.fit: time-stretch (pitch kept, ffmpeg atempo) a line that is too long for its slot,
    # so a second-language version keeps the same timeline; at most voice.max_speed (default 1.3)
    if voice.get('fit') and dur > slot - 0.2:
        speed = min(voice.get('max_speed', 1.3), dur / (slot - 0.25))
        tmp = path + '.tmp.wav'
        subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', path, '-filter:a', f'atempo={speed:.4f}', tmp], check=True)
        os.replace(tmp, path)
        dur = sf.info(path).duration
    flag = '' if dur <= slot - 0.15 else '  <-- too long for its slot'
    print(f"{line['id']:>4}  {dur:5.2f}s / slot {slot:5.2f}s  speed {speed:.2f}{flag}")
print(f'voice → {out_dir}')

#!/usr/bin/env python3
"""Generate the voice-over lines of an episode.

voice.engine in episode.json:
  "kokoro"   English, offline via sherpa-onnx (default)
  "paxa"     Thai/English/Mandarin, Paxa Labs API (https://api.paxalabs.com). Needs PAXA_API_KEY in the
             environment. From a cloud session the API is not reachable: the GitHub Actions workflow
             .github/workflows/voice-paxa.yml runs this script with the repo secret PAXA_API_KEY.
  "mms-tha"  Thai, offline Meta MMS-TTS (CC BY-NC 4.0: non-commercial use only; flat-sounding fallback)

usage: python3 engine/tts.py episodes/<name> [--speaker ID] [--out-dir DIR]
Writes <out-dir>/<id>.wav (default .cache/<name>/voice) and prints each line's duration next to the
time slot it has. A ' | ' in a line's text is a phrase break (voiced separately, joined with voice.gap s of
silence). voice.fit: true time-stretches a line that is too long for its slot (ffmpeg atempo,
pitch kept, at most voice.max_speed, default 1.3), so a second-language version keeps the timeline.
"""
import argparse, json, os, subprocess, sys, time, urllib.request, urllib.error
import soundfile as sf

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KOKORO = os.path.join(ROOT, '.cache', 'kokoro', 'kokoro-int8-en-v0_19')
MMS_THA = os.path.join(ROOT, '.cache', 'mms-tha', 'vits-mms-tha')
# Kokoro v0.19 speaker ids
SPEAKERS = {'af': 0, 'af_bella': 1, 'af_nicole': 2, 'af_sarah': 3, 'af_sky': 4,
            'am_adam': 5, 'am_michael': 6, 'bf_emma': 7, 'bf_isabella': 8,
            'bm_george': 9, 'bm_lewis': 10}

ap = argparse.ArgumentParser()
ap.add_argument('episode')
ap.add_argument('--speaker', help='override voice.speaker (e.g. try another Paxa voice)')
ap.add_argument('--out-dir', help='override the output folder')
a = ap.parse_args()

ep_dir = os.path.abspath(a.episode)
name = os.path.basename(ep_dir)
ep = json.load(open(os.path.join(ep_dir, 'episode.json')))
voice = dict(ep['voice'])
if a.speaker:
    voice['speaker'] = a.speaker
out_dir = os.path.abspath(a.out_dir) if a.out_dir else os.path.join(ROOT, '.cache', name, 'voice')
os.makedirs(out_dir, exist_ok=True)
engine = voice.get('engine', 'kokoro')


def sherpa_engine():
    import sherpa_onnx
    if engine == 'mms-tha':
        if not os.path.exists(os.path.join(MMS_THA, 'model.onnx')):
            sys.exit('Thai model missing. Run ./setup.sh --thai first.')
        cfg = sherpa_onnx.OfflineTtsModelConfig(vits=sherpa_onnx.OfflineTtsVitsModelConfig(
            model=os.path.join(MMS_THA, 'model.onnx'), tokens=os.path.join(MMS_THA, 'tokens.txt')), num_threads=4)
        sid = 0
        # the MMS vocabulary has no SARA AM (U+0E33): split it into NIKHAHIT + SARA AA.
        # Write numbers as Thai words; the model reads only Thai letters.
        prep = lambda text: text.replace('ำ', 'ํา')
    else:
        if not os.path.exists(os.path.join(KOKORO, 'model.int8.onnx')):
            sys.exit('Kokoro model missing. Run ./setup.sh first.')
        cfg = sherpa_onnx.OfflineTtsModelConfig(kokoro=sherpa_onnx.OfflineTtsKokoroModelConfig(
            model=os.path.join(KOKORO, 'model.int8.onnx'), voices=os.path.join(KOKORO, 'voices.bin'),
            tokens=os.path.join(KOKORO, 'tokens.txt'), data_dir=os.path.join(KOKORO, 'espeak-ng-data')), num_threads=4)
        sid = SPEAKERS[voice.get('speaker', 'af_bella')]
        prep = lambda text: text
    tts = sherpa_onnx.OfflineTts(sherpa_onnx.OfflineTtsConfig(model=cfg))

    def synth(text, path):
        audio = tts.generate(prep(text), sid=sid, speed=voice.get('speed', 1.0))
        sf.write(path, audio.samples, audio.sample_rate)
    return synth


def paxa_engine():
    key = os.environ.get('PAXA_API_KEY', '').strip()
    if not key:
        sys.exit('PAXA_API_KEY is not set (GitHub: Settings → Secrets and variables → Actions → PAXA_API_KEY).')
    base = os.environ.get('PAXA_BASE_URL', 'https://api.paxalabs.com').rstrip('/')

    def synth(text, path):
        body = {'model': voice.get('model', 'paxa-tts-flash-v2'), 'text': text,
                'voice': voice.get('speaker', 'foithong'), 'format': 'wav', 'stream': False,
                'language': voice.get('language', 'th'), 'speed': voice.get('speed', 1.0)}
        for attempt in range(8):
            req = urllib.request.Request(base + '/v1/tts', data=json.dumps(body).encode(), method='POST',
                                         headers={'Authorization': f'Bearer {key}', 'Content-Type': 'application/json'})
            try:
                with urllib.request.urlopen(req, timeout=120) as r:
                    data = r.read()
                break
            except urllib.error.HTTPError as e:
                msg = e.read().decode(errors='replace')[:300]
                if e.code in (429, 500, 502, 503) and attempt < 7:
                    # rate limit: honour Retry-After, else back off 15, 30, 45 ... s (max 90)
                    wait = e.headers.get('Retry-After') if e.headers else None
                    wait = float(wait) if wait and wait.replace('.', '', 1).isdigit() else min(90, 15 * (attempt + 1))
                    print(f'  Paxa {e.code}, retry in {wait:.0f}s', flush=True)
                    time.sleep(wait); continue
                sys.exit(f'Paxa API error {e.code}: {msg}')
        with open(path, 'wb') as f:
            f.write(data)
    return synth


synth = paxa_engine() if engine == 'paxa' else sherpa_engine()
lines = ep['voiceover']
print(f"engine {engine}  speaker {voice.get('speaker', '-')}")
for i, line in enumerate(lines):
    path = os.path.join(out_dir, f"{line['id']}.wav")
    parts = [x.strip() for x in line['text'].split('|') if x.strip()]
    if len(parts) == 1:
        synth(parts[0], path)
    else:
        # ' | ' in the text = a phrase break: each phrase is voiced on its own and joined with voice.gap s of
        # silence (default 0.28), so engines that run Thai phrases together still pause where the script says
        import numpy as np
        chunks, sr = [], None
        for k, part in enumerate(parts):
            tmp = f'{path}.part{k}.wav'
            synth(part, tmp)
            d, r = sf.read(tmp, dtype='float32', always_2d=True)
            os.remove(tmp)
            sr = sr or r
            if r != sr:
                sys.exit(f"{line['id']}: phrase sample rates differ ({r} vs {sr})")
            if chunks:
                chunks.append(np.zeros((int(sr * voice.get('gap', 0.28)), d.shape[1]), dtype='float32'))
            chunks.append(d)
        sf.write(path, np.concatenate(chunks), sr, subtype='PCM_16')
    dur = sf.info(path).duration
    nxt = lines[i + 1]['at'] if i + 1 < len(lines) else ep['duration']
    slot = nxt - line['at']
    speed = 1.0
    if voice.get('fit') and dur > slot - 0.2:
        speed = min(voice.get('max_speed', 1.3), dur / (slot - 0.25))
        tmp = path + '.tmp.wav'
        subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', path, '-filter:a', f'atempo={speed:.4f}', tmp], check=True)
        os.replace(tmp, path)
        dur = sf.info(path).duration
    flag = '' if dur <= slot - 0.15 else '  <-- too long for its slot'
    print(f"{line['id']:>4}  {dur:5.2f}s / slot {slot:5.2f}s  stretch {speed:.2f}{flag}")
print(f'voice → {out_dir}')

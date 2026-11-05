#!/usr/bin/env python3
"""Querious sonic identity: Minimal Electronic Ambient (brand/sonic-identity.md, section 11).

usage: python3 engine/music.py <duration_seconds> <out.wav> [--section 13.5]

Works for any clip length. Sections keep a fixed length (13.5 s by default) and the
chord cycle Am -> G -> F -> Em/G repeats for as long as the clip needs. A tail shorter
than 4 s is folded into the last section, so there is never a stub chord at the end.
The last chord holds until the final frame; one 3 s fade-out ends exactly at <duration>.
Soft plucks every 1.5 s, fade-in 2.5 s, peak 0.23 (about -13 dBFS).
"""
import argparse, math, wave
import numpy as np

ap = argparse.ArgumentParser()
ap.add_argument('duration', nargs='?', type=float, default=54.0)
ap.add_argument('out', nargs='?', default='querious-original-ambient.wav')
ap.add_argument('--section', type=float, default=13.5, help='seconds per chord (default 13.5)')
a = ap.parse_args()

sr = 44100
duration = a.duration
t = np.arange(int(sr * duration)) / sr
music = np.zeros_like(t)

chords = [
    [220, 261.63, 329.63, 440],      # Am  (A3 C4 E4 A4)
    [196, 246.94, 293.66, 392],      # G   (G3 B3 D4 G4)
    [174.61, 220, 261.63, 349.23],   # F   (F3 A3 C4 F4)
    [196, 246.94, 329.63, 392],      # Em/G (G3 B3 E4 G4)
]
pluck_pitch = [440, 493.88, 523.25, 392]   # A4 B4 C5 G4, one per chord

# Section boundaries: fixed length, short tail (< 4 s) merged into the last section
n = max(1, math.floor(duration / a.section))
if duration - n * a.section >= 4.0:
    n += 1
starts = [i * a.section for i in range(n)]
ends = starts[1:] + [duration]
XF = 2.2  # equal-power crossfade between chords (s), centred on the boundary

# Warm ambient pads: crossfade between sections; no envelope at the very start or end
for s, (st, en) in enumerate(zip(starts, ends)):
    rise = np.sin(0.5 * np.pi * np.clip((t - st + XF / 2) / XF, 0, 1)) if s > 0 else 1.0       # first chord: global fade-in only
    fall = np.sin(0.5 * np.pi * np.clip((en + XF / 2 - t) / XF, 0, 1)) if s < n - 1 else 1.0   # last chord: holds to the end
    env = rise * fall
    for j, f in enumerate(chords[s % 4]):
        music += 0.042 * env * (np.sin(2 * np.pi * f * t + 0.3 * j)
                                + 0.18 * np.sin(2 * np.pi * 2 * f * t)) / (j + 1) ** 0.35

# Soft electronic plucks on the 1.5 s grid, until 1.5 s before the end
for beat in np.arange(1.5, duration - 1.5, 1.5):
    idx = int(beat * sr)
    length = min(int(1.4 * sr), len(t) - idx)
    tt = np.arange(length) / sr
    s = sum(1 for st in starts if st <= beat) - 1
    f = pluck_pitch[s % 4]
    music[idx:idx + length] += 0.023 * np.exp(-tt * 3.8) * np.sin(2 * np.pi * f * tt)

# One fade-in, one fade-out that lands exactly on the last frame
music *= np.minimum(1, t / 2.5)
music *= np.sin(0.5 * np.pi * np.clip((duration - t) / 3.0, 0, 1))
music /= max(np.max(np.abs(music)), 1e-9)
music *= 0.23

with wave.open(a.out, 'wb') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(sr)
    w.writeframes((music * 32767).astype('<i2').tobytes())
names = ['Am', 'G', 'F', 'Em/G']
print(f"music → {a.out}  ({duration:.1f}s, {n} sections: {' '.join(names[i % 4] for i in range(n))})")

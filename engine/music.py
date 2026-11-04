#!/usr/bin/env python3
"""Querious sonic identity: Minimal Electronic Ambient (brand/sonic-identity.md, section 11).

usage: python3 engine/music.py <duration_seconds> <out.wav>
4 sections, one chord each (Am -> G -> F -> Em/G); section length = duration / 4.
Soft plucks every 1.5 s, fade-in 2.5 s, fade-out 3 s, peak 0.23 (about -13 dBFS).
"""
import sys, wave
import numpy as np

duration = float(sys.argv[1]) if len(sys.argv) > 1 else 54.0
path = sys.argv[2] if len(sys.argv) > 2 else 'querious-original-ambient.wav'
sr = 44100
section = duration / 4
t = np.arange(int(sr * duration)) / sr
music = np.zeros_like(t)

chords = [
    [220, 261.63, 329.63, 440],      # Am  (A3 C4 E4 A4)
    [196, 246.94, 293.66, 392],      # G   (G3 B3 D4 G4)
    [174.61, 220, 261.63, 349.23],   # F   (F3 A3 C4 F4)
    [196, 246.94, 329.63, 392],      # Em/G (G3 B3 E4 G4)
]

for s in range(4):
    start = s * section
    env = np.clip((t - start) / 2.2, 0, 1) * np.clip((start + section - t) / 2.2, 0, 1)
    for j, f in enumerate(chords[s]):
        music += 0.042 * env * (np.sin(2 * np.pi * f * t + 0.3 * j)
                                + 0.18 * np.sin(2 * np.pi * 2 * f * t)) / (j + 1) ** 0.35

for beat in np.arange(1.5, duration - 1, 1.5):
    idx = int(beat * sr)
    length = min(int(1.4 * sr), len(t) - idx)
    tt = np.arange(length) / sr
    f = [440, 493.88, 523.25, 392][min(3, int(beat // section))]   # A4 B4 C5 G4
    music[idx:idx + length] += 0.023 * np.exp(-tt * 3.8) * np.sin(2 * np.pi * f * tt)

music *= np.minimum(1, t / 2.5)
music *= np.minimum(1, (duration - t) / 3)
music /= max(np.max(np.abs(music)), 1e-9)
music *= 0.23

with wave.open(path, 'wb') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(sr)
    w.writeframes((music * 32767).astype('<i2').tobytes())
print(f'music → {path}')

# Audio Settings for YouTube

## Target Loudness
- Integrated: **-14 LUFS**
- True Peak: **-1 dBFS**
- Loudness Range: 5-8 LU

---

## EQ Settings (Voice)

| Frequency | Action | Reason |
|-----------|--------|--------|
| 80Hz and below | High-pass cut | Remove rumble/room noise |
| 100-200Hz | Cut 2-3dB (Q=1.5) | Reduce muddiness/boominess |
| 250-400Hz | Cut 1-2dB (Q=1.5) | Reduce boxiness |
| 2-4kHz | Boost 2-3dB (Q=1.0) | Add clarity/presence |
| 6-10kHz | Shelf boost 1-2dB | Add air/brightness |

---

## Compressor Settings

| Parameter | Value |
|-----------|-------|
| Threshold | -18dB |
| Ratio | 3:1 |
| Attack | 10-20ms |
| Release | 100-150ms |
| Makeup Gain | Adjust to match original loudness |

---

## Limiter Settings

| Parameter | Value |
|-----------|-------|
| Ceiling/Output | -1dB |

---

## OBS Audio Filters (in order)

1. **Noise Suppression** (RNNoise)
2. **Gain** (if mic is too quiet)
3. **3-Band EQ** or **VST Plugin**
   - Low: -2dB
   - Mid: 0dB
   - High: +2dB
4. **Compressor**
   - Ratio: 3:1
   - Threshold: -18dB
   - Attack: 10ms
   - Release: 100ms
   - Output Gain: 0dB (adjust as needed)
5. **Limiter**
   - Threshold: -1dB
   - Release: 60ms

---

## OBS Advanced EQ (VST Plugin)

If using VST plugin (like ReaEQ, TDR Nova):
- High-pass: 80Hz, 12dB/oct
- Cut: 150Hz, -2dB, Q=1.5
- Cut: 300Hz, -1dB, Q=1.5
- Boost: 3kHz, +2dB, Q=1.0
- High-shelf: 8kHz, +1.5dB

---

## DaVinci Resolve Fairlight

1. Add EQ → set bands as above
2. Add Compressor → Dynamics → Compressor
3. Add Limiter → Dynamics → Limiter
4. Normalize: Right-click clip → Normalize Audio Levels → -14 LUFS

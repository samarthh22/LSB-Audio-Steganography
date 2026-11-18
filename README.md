# LSB Audio Steganography

This MATLAB project embeds a UTF-8 message in the least significant bits of a 16-bit mono PCM WAV. It extracts the message from the saved WAV and measures the audio changes with waveform comparisons, error metrics, and a one-dimensional DFT.

## Run the demo

Open `START_HERE.m` in MATLAB and click **Run**. The script uses the included `data/cover_demo.wav`, runs the automated tests, and compares the default results with the fixtures in `reference_results/`. Base MATLAB is sufficient.

Open `outputs/` after the run for the stego WAV, waveform and DFT plots, payload sweep, and LSB-erasure experiment results.

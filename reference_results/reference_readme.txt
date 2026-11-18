REFERENCE RUN (not MATLAB execution)
This directory contains PCM-level values obtained by an independent verification routine.
Source: ../data/cover_demo.wav (mono, PCM16, 44,100 Hz, 6 seconds).
The algorithm uses the identical 32-bit big-endian byte-length header, UTF-8 bytes, sequential 1-LSB PCM substitution, and 1D Hann-windowed FFT.
Run MATLAB/run_project.m to generate real MATLAB outputs. Compare outputs/*.csv and outputs/results_summary.txt with these expectations.
The MATLAB-generated WAV should match reference_stego.wav sample-for-sample; WAV metadata may differ.

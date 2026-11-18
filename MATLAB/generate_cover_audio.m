function outputFile = generate_cover_audio(outputFile)
%GENERATE_COVER_AUDIO Deterministic 6-second 44.1-kHz PCM16 test waveform.
% Uses three additive components plus a slow amplitude envelope; no toolbox.
    Fs = 44100;
    seconds = 6;
    n = (0:(Fs * seconds - 1)).';
    t = n / Fs;
    chirpPhase = 2*pi*(230*t + 0.5*(550/seconds)*t.^2);
    base = 0.38*sin(2*pi*440*t) + 0.19*sin(2*pi*880*t) ...
         + 0.09*sin(chirpPhase);
    rise = min(1, t/0.03);
    fall = min(1, (seconds - t)/0.03);
    envelope = (0.8 + 0.2*sin(2*pi*0.6*t).^2) .* rise .* fall;
    x = base .* envelope;
    if max(abs(x)) > 1
        error('DSP:GeneratorClipping', 'Synthesized amplitude exceeds full scale.');
    end
    samples = int16(round(32767 * x));
    audiowrite(outputFile, samples, Fs, 'BitsPerSample', 16);
end

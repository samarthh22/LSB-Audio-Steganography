function dft = plot_analysis(coverFile, stegoFile, outFolder)
%PLOT_ANALYSIS Compare waveform, 1D FFT and spectral residual (base MATLAB).
    [a, Fs] = audioread(coverFile, 'native');
    [b, ~] = audioread(stegoFile, 'native');
    x = double(a(:)) / 32768;
    y = double(b(:)) / 32768;
    if ~exist(outFolder,'dir'), mkdir(outFolder); end

    showN = min(round(0.025*Fs), numel(x));
    tt = (0:showN-1)'/Fs*1000;
    f1 = figure('Visible','off','Color','w','Position',[100 100 980 480]);
    subplot(2,1,1);
    plot(tt, x(1:showN), 'b-','LineWidth',0.9); hold on;
    plot(tt, y(1:showN),'r--','LineWidth',0.7);
    xlabel('Time (ms)'); ylabel('Normalized amplitude');
    title('Cover and stego audio (first 25 ms)'); legend('Cover','Stego'); grid on;
    subplot(2,1,2);
    stairs(tt, (y(1:showN) - x(1:showN))*32768,'k-');
    xlabel('Time (ms)'); ylabel('Difference (PCM counts)');
    title('Sample-wise embedding perturbation (-1, 0, or +1)'); grid on;
    print(f1, fullfile(outFolder,'fig_01_waveforms.png'),'-dpng','-r150'); close(f1);

    nFft = min(4096, numel(x));
    w = 0.5 - 0.5*cos((2*pi*(0:nFft-1)')/(nFft-1));
    X = fft(x(1:nFft).*w);
    Y = fft(y(1:nFft).*w);
    E = Y-X;
    k = 1:(floor(nFft/2)+1);
    freq = (k-1)'*Fs/nFft;
    scale = 2/sum(w);
    pX = 20*log10(max(abs(X(k))*scale,1e-15));
    pY = 20*log10(max(abs(Y(k))*scale,1e-15));
    pE = 20*log10(max(abs(E(k))*scale,1e-15));
    f2 = figure('Visible','off','Color','w','Position',[100 100 980 520]);
    subplot(2,1,1);
    plot(freq,pX,'b-','LineWidth',1.0); hold on;
    plot(freq,pY,'r--','LineWidth',0.8);
    title('One-sided 1D DFT magnitude (4096 samples, Hann window)');
    xlabel('Frequency (Hz)'); ylabel('Amplitude (dB re full scale)');
    legend('Cover','Stego'); grid on; xlim([0 min(4000,Fs/2)]);
    subplot(2,1,2);
    plot(freq,pE,'k-');
    title('Magnitude of complex spectral difference FFT(stego-cover)');
    xlabel('Frequency (Hz)'); ylabel('Residual amplitude (dB re full scale)');
    grid on; xlim([0 min(4000,Fs/2)]);
    print(f2, fullfile(outFolder,'fig_02_dft.png'),'-dpng','-r150'); close(f2);
    if norm(X) == 0
        residualDb = NaN;
    elseif norm(E) == 0
        residualDb = -Inf;
    else
        residualDb = 20*log10(norm(E)/norm(X));
    end
    dft.fftLength = nFft;
    dft.window = 'Hann (manually computed)';
    dft.spectralResidualDb = residualDb;
    dft.parsevalError = abs(norm(E)^2/nFft - ...
        sum(((y(1:nFft)-x(1:nFft)).*w).^2));
end

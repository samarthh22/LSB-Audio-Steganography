function result = run_project(customCoverFile, customMessage)
%RUN_PROJECT One-click end-to-end demonstration for the DSP Lab project.
%
% In MATLAB: open this folder and run:  run_project
% Optionally: run_project('C:\\path\\to\\mono16.wav','Your message')
% Requires base MATLAB; 16-bit uncompressed mono WAV (not MP3).
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(root,'MATLAB'));
    dataDir = fullfile(root,'data');
    outDir = fullfile(root,'outputs');
    if ~exist(dataDir,'dir'), mkdir(dataDir); end
    if ~exist(outDir,'dir'), mkdir(outDir); end
    if nargin < 1 || isempty(customCoverFile)
        coverFile = fullfile(dataDir,'cover_demo.wav');
        if ~exist(coverFile,'file')
            generate_cover_audio(coverFile);
        end
    else
        coverFile = char(customCoverFile);
        if ~exist(coverFile,'file')
            error('DSP:MissingInput','Cover WAV not found: %s',coverFile);
        end
    end
    if nargin < 2 || isempty(customMessage)
        message = 'DSP Lab 2026: audio message hidden using LSB.';
    else
        message = char(customMessage);
    end
    stegoFile = fullfile(outDir,'stego_demo.wav');
    meta = lsb_embed(coverFile,stegoFile,message);
    [recovered,~] = lsb_extract(stegoFile);
    q = quality_metrics(coverFile,stegoFile,message,recovered);
    assert(q.exactRecovery, 'The message was not recovered exactly.');
    dft = plot_analysis(coverFile,stegoFile,outDir);
    sweep = run_payload_sweep(coverFile,outDir);
    attack = run_attack_demo(stegoFile,message,outDir);
    result.embedding = meta;
    result.quality = q;
    result.dft = dft;
    result.sweep = sweep;
    result.attack = attack;
    result.recoveredText = recovered;
    save(fullfile(outDir,'run_results.mat'),'result');
    fid = fopen(fullfile(outDir,'results_summary.txt'),'w');
    if fid == -1, error('DSP:WriteFailure','Cannot write results_summary.txt.'); end
    fprintf(fid,'DSP Lab project: audio LSB and 1D DFT\n');
    fprintf(fid,'Cover: %s\nStego: %s\n',coverFile,stegoFile);
    fprintf(fid,'Sample rate: %d Hz\nSamples: %d\n',meta.sampleRate,meta.sampleCount);
    fprintf(fid,'Header bits: %d\nMessage bytes (UTF-8): %d\n',meta.headerBits,meta.messageBytes);
    fprintf(fid,'Total embedded bits: %d\nCapacity: %d bytes\n',meta.payloadBits,meta.capacityBytes);
    fprintf(fid,'Recovered text: %s\n',recovered);
    fprintf(fid,'MSE normalized: %.12g\nPSNR dBFS: %.5f\nSNR dB: %.5f\n', ...
        q.mseNormalized,q.psnrDbFS,q.snrDb);
    fprintf(fid,'Message BER: %.8f\nChanged PCM samples: %d\n',q.messageBER,q.changedSamples);
    fprintf(fid,'Maximum PCM count change: %.0f\n',q.maxPcmDifference);
    fprintf(fid,'4096-sample Hann-window DFT residual ratio (dB): %.5f\n',dft.spectralResidualDb);
    fprintf(fid,'LSB erasure raw payload BER: %.6f; recovered bytes: %.0f\n', ...
        attack.RawPayloadBER,attack.RecoveredMessageBytes);
    fclose(fid);
    fprintf('\n=== DSP LAB: RUN COMPLETED ===\n');
    fprintf('Samples: %d | Fs: %d Hz | payload: %d bits\n', ...
        meta.sampleCount,meta.sampleRate,meta.payloadBits);
    fprintf('Recovered: %s\n',recovered);
    fprintf('MSE (normalized): %.12g | PSNR: %.5f dBFS | SNR: %.5f dB\n', ...
        q.mseNormalized,q.psnrDbFS,q.snrDb);
    fprintf('Message BER: %.8f | changed samples: %d | max PCM delta: %.0f\n', ...
        q.messageBER,q.changedSamples,q.maxPcmDifference);
    fprintf('Spectral residual: %.5f dB | LSB-erasure BER: %.4f\n', ...
        dft.spectralResidualDb,attack.RawPayloadBER);
    fprintf('Saved WAV, CSV, figures, and summary under: %s\n',outDir);
end

function verify_reference()
%VERIFY_REFERENCE Compare default MATLAB run to independently checked WAV.
% Run after run_project WITHOUT custom arguments; do not use for custom WAV.
    root = fileparts(fileparts(mfilename('fullpath')));
    coverFile = fullfile(root,'data','cover_demo.wav');
    matlabStego = fullfile(root,'outputs','stego_demo.wav');
    expectedStego = fullfile(root,'reference_results','reference_stego.wav');
    [actual, actualFs] = audioread(matlabStego,'native');
    [expected, expectedFs] = audioread(expectedStego,'native');
    if ~(actualFs == expectedFs && isequal(actual,expected))
        error('DSP:ReferenceMismatch','Stego WAV samples do not match reference.');
    end
    [recovered,~] = lsb_extract(matlabStego);
    message = 'DSP Lab 2026: audio message hidden using LSB.';
    if ~strcmp(recovered,message)
        error('DSP:ReferenceMismatch','Recovered text mismatch.');
    end
    m = quality_metrics(coverFile,matlabStego,message,recovered);
    t = readtable(fullfile(root,'reference_results','expected_metrics.csv'));
    assert(m.changedSamples == t.ChangedSamples(1),'Changed sample count mismatch.');
    assert(abs(m.mseNormalized-t.MSE_Normalized(1)) < 1e-19,'MSE mismatch.');
    assert(abs(m.psnrDbFS-t.PSNR_dBFS(1)) < 1e-8,'PSNR mismatch.');
    assert(abs(m.snrDb-t.SNR_dB(1)) < 1e-8,'SNR mismatch.');
    s = readtable(fullfile(root,'outputs','payload_sweep.csv'));
    sr = readtable(fullfile(root,'reference_results','expected_payload_sweep.csv'));
    assert(isequal(s.MessageBytes,sr.MessageBytes),'Sweep lengths mismatch.');
    assert(isequal(s.ChangedSamples,sr.ChangedSamples),'Sweep changed samples mismatch.');
    assert(all(abs(s.PSNR_dBFS-sr.PSNR_dBFS)<1e-8),'Sweep PSNR mismatch.');
    fprintf('PASS: MATLAB output WAV matches independent reference sample-for-sample.\n');
    fprintf('PASS: Extracted text, MSE, PSNR, SNR, changed count and sweep all match.\n');
end

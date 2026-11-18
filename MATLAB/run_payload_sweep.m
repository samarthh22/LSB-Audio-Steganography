function results = run_payload_sweep(coverFile, outFolder)
%RUN_PAYLOAD_SWEEP Re-run embedding at five message lengths for comparison.
    if ~exist(outFolder,'dir'), mkdir(outFolder); end
    lengths = [32 128 512 2048 8192];
    n = numel(lengths);
    messages = cell(1,n);
    messageBER = zeros(n,1);
    mse = zeros(n,1);
    psnr = zeros(n,1);
    snr = zeros(n,1);
    changed = zeros(n,1);
    embeddedBits = zeros(n,1);
    template = 'DSP-LAB-2026|';
    tempFile = fullfile(outFolder,'_sweep_temporary.wav');
    for i = 1:n
        message = repmat(template,1,ceil(lengths(i)/numel(template)));
        message = message(1:lengths(i));
        messages{i} = message;
        meta = lsb_embed(coverFile, tempFile, message);
        recovered = lsb_extract(tempFile);
        q = quality_metrics(coverFile,tempFile,message,recovered);
        if ~q.exactRecovery || q.maxPcmDifference > 1
            error('DSP:SweepValidationFailed', 'Payload sweep failed at length %d.',lengths(i));
        end
        messageBER(i) = q.messageBER;
        mse(i) = q.mseNormalized;
        psnr(i) = q.psnrDbFS;
        snr(i) = q.snrDb;
        changed(i) = q.changedSamples;
        embeddedBits(i) = meta.payloadBits;
    end
    if exist(tempFile,'file'), delete(tempFile); end
    results = table(lengths(:),embeddedBits,changed,mse,psnr,snr,messageBER, ...
        'VariableNames',{'MessageBytes','EmbeddedBits','ChangedSamples', ...
        'MSE_Normalized','PSNR_dBFS','SNR_dB','MessageBER'});
    writetable(results,fullfile(outFolder,'payload_sweep.csv'));
    f = figure('Visible','off','Color','w','Position',[100 100 860 440]);
    plot(lengths,psnr,'o-','LineWidth',1.6,'MarkerSize',6);
    xlabel('Text payload (bytes)'); ylabel('PSNR (dBFS)');
    title('Observed distortion versus message size (same 6-second cover)');
    grid on;
    print(f,fullfile(outFolder,'fig_03_payload_sweep.png'),'-dpng','-r150'); close(f);
end

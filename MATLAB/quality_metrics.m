function m = quality_metrics(coverFile, stegoFile, originalMessage, recoveredMessage)
%QUALITY_METRICS Calculate metrics on common full-scale-normalized units.
% PCM16 -> normalized signal x = PCM / 32768 (0 dBFS reference = 1).
    [a, FsA] = audioread(coverFile, 'native');
    [b, FsB] = audioread(stegoFile, 'native');
    if ~isa(a,'int16') || ~isa(b,'int16') || ~isequal(size(a),size(b)) || FsA ~= FsB
        error('DSP:IncompatibleAudio', 'Use equal-length PCM16 files at the same rate.');
    end
    x = double(a(:)) / 32768;
    y = double(b(:)) / 32768;
    d = x - y;
    mse = mean(d.^2);
    signalPower = mean(x.^2);
    if mse == 0
        psnrDb = Inf;
        snrDb = Inf;
    else
        psnrDb = 10*log10(1/mse); % Fixed full-scale peak: 1, not 255.
        snrDb = 10*log10(signalPower/mse);
    end
    sentBytes = uint8(unicode2native(char(originalMessage), 'UTF-8'));
    recvBytes = uint8(unicode2native(char(recoveredMessage), 'UTF-8'));
    sentBits = bytes_to_bits(sentBytes);
    recvBits = bytes_to_bits(recvBytes);
    if numel(sentBits) ~= numel(recvBits)
        ber = NaN; % Comparing differently sized messages is not meaningful.
        exactRecovery = false;
    elseif isempty(sentBits)
        ber = 0;
        exactRecovery = true;
    else
        ber = sum(sentBits ~= recvBits) / numel(sentBits);
        exactRecovery = isequal(sentBytes(:), recvBytes(:));
    end
    m.sampleRate = FsA;
    m.sampleCount = numel(a);
    m.mseNormalized = mse;
    m.psnrDbFS = psnrDb;
    m.snrDb = snrDb;
    m.messageBER = ber;
    m.exactRecovery = exactRecovery;
    m.changedSamples = nnz(a(:) ~= b(:));
    m.maxPcmDifference = max(abs(double(a(:)) - double(b(:))));
end

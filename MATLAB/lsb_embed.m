function info = lsb_embed(coverFile, stegoFile, message)
%LSB_EMBED Hide UTF-8 text in 16-bit PCM mono WAV, one bit per sample.
% Protocol: 32-bit unsigned big-endian payload length IN BYTES, followed
% by payload bytes MSB-first. This protocol must match lsb_extract.m.
% The WAV sample rate and all samples outside the payload are unchanged.
    if isstring(message)
        message = char(message);
    end
    if ~ischar(message)
        error('DSP:InvalidMessage', 'Message must be a character vector or string.');
    end
    if ~ischar(coverFile) && ~isstring(coverFile)
        error('DSP:InvalidPath', 'Cover file path must be text.');
    end
    coverFile = char(coverFile);
    stegoFile = char(stegoFile);
    wavInfo = audioinfo(coverFile);
    [samples, Fs] = audioread(coverFile, 'native');
    if wavInfo.BitsPerSample ~= 16 || ~isa(samples, 'int16') || size(samples,2) ~= 1
        error('DSP:UnsupportedCover', ...
            'Use an uncompressed 16-bit PCM MONO WAV. Do not convert silently.');
    end
    bytes = uint8(unicode2native(message, 'UTF-8'));
    numBytes = numel(bytes);
    if numBytes > double(intmax('uint32'))
        error('DSP:PayloadTooLarge', 'Message exceeds the 32-bit length field.');
    end
    % Length is encoded in 32 MSB-first bits; length is a BYTE count.
    hdr = uint8(bitget(uint32(numBytes), 32:-1:1)).';
    bits = [hdr; bytes_to_bits(bytes)];
    numBits = numel(bits);
    N = numel(samples);
    maxBytes = max(0, floor((N - 32) / 8));
    if numBits > N
        error('DSP:InsufficientCapacity', ...
            'Need %d samples; audio has %d samples. Max payload = %d bytes.', ...
            numBits, N, maxBytes);
    end
    % TYPECAST preserves the two's-complement bit pattern of signed PCM.
    uintSamples = typecast(samples(:), 'uint16');
    uintSamples(1:numBits) = bitor( ...
        bitand(uintSamples(1:numBits), uint16(65534)), uint16(bits));
    stegoSamples = reshape(typecast(uintSamples(:), 'int16'), size(samples));
    audiowrite(stegoFile, stegoSamples, Fs, 'BitsPerSample', 16);
    % Confirm that writing to disk has not re-quantized any PCM samples.
    [saved, savedFs] = audioread(stegoFile, 'native');
    if ~isa(saved, 'int16') || savedFs ~= Fs || ~isequal(saved, stegoSamples)
        error('DSP:NonLosslessOutput', 'Saved file did not preserve exact PCM samples.');
    end
    info.sampleRate = Fs;
    info.sampleCount = N;
    info.headerBits = 32;
    info.messageBytes = numBytes;
    info.payloadBits = numBits;
    info.capacityBytes = maxBytes;
    info.payloadOccupancyPercent = 100 * numBits / N;
end

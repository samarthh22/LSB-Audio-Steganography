function [message, info] = lsb_extract(stegoFile)
%LSB_EXTRACT Recover UTF-8 text from an unmodified stego 16-bit PCM WAV.
% WARNING: No encryption or integrity check is provided in this baseline.
    wavInfo = audioinfo(stegoFile);
    [samples, Fs] = audioread(stegoFile, 'native');
    if wavInfo.BitsPerSample ~= 16 || ~isa(samples,'int16') || size(samples,2) ~= 1
        error('DSP:UnsupportedStego', 'Expected a 16-bit PCM MONO WAV file.');
    end
    N = numel(samples);
    if N < 32
        error('DSP:DamagedHeader', 'Not enough samples for the 32-bit header.');
    end
    values = typecast(samples(:), 'uint16');
    headBits = uint8(bitget(values(1:32), 1));
    length32 = uint32(0);
    for i = 1:32
        length32 = bitor(bitshift(length32, 1), uint32(headBits(i)));
    end
    numBytes = double(length32);
    if numBytes > floor((N - 32) / 8)
        error('DSP:DamagedHeader', ...
            'Decoded header requests %g bytes, exceeding WAV capacity.', numBytes);
    end
    count = 8 * numBytes;
    messageBits = uint8(bitget(values(33:32+count), 1));
    byteValues = bits_to_bytes(messageBits);
    message = native2unicode(byteValues, 'UTF-8');
    info.sampleRate = Fs;
    info.headerBits = 32;
    info.messageBytes = numBytes;
    info.messageBits = messageBits;
end

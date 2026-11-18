function byteValues = bits_to_bytes(bits)
%BITS_TO_BYTES Reassemble an MSB-first bit column into uint8 bytes.
    bits = uint8(bits(:));
    if mod(numel(bits), 8) ~= 0
        error('DSP:InvalidBitCount', 'The bit count must be divisible by 8.');
    end
    if isempty(bits)
        byteValues = zeros(1, 0, 'uint8');
        return;
    end
    bitMatrix = reshape(double(bits), 8, []);
    weights = (2.^(7:-1:0)).';
    byteValues = uint8(weights.' * bitMatrix);
end

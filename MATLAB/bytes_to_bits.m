function bits = bytes_to_bits(byteValues)
%BYTES_TO_BITS Convert uint8 bytes to a column of MSB-first bits.
% Each byte contributes eight bits, from bit 8 down to bit 1.
    byteValues = uint8(byteValues(:));
    if isempty(byteValues)
        bits = zeros(0, 1, 'uint8');
        return;
    end
    positions = repmat(8:-1:1, numel(byteValues), 1);
    values = repmat(byteValues, 1, 8);
    bitMatrix = uint8(bitget(values, positions));
    bits = reshape(bitMatrix.', [], 1);
end

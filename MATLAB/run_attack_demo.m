function attack = run_attack_demo(stegoFile, message, outFolder)
%RUN_ATTACK_DEMO Clear LSBs to demonstrate weakness to bit-plane erasure.
% NOT a simulated compression test; it is a controlled destructive edit.
    [samples, Fs] = audioread(stegoFile,'native');
    originals = typecast(samples(:),'uint16');
    wiped = bitand(originals,uint16(65534));
    attackedSamples = reshape(typecast(wiped(:),'int16'),size(samples));
    attackedFile = fullfile(outFolder,'attacked_lsb_cleared.wav');
    audiowrite(attackedFile,attackedSamples,Fs,'BitsPerSample',16);
    [attackedRead,~] = audioread(attackedFile,'native');
    assert(isequal(attackedRead,attackedSamples),'Attack WAV changed during writing.');
    expectedBytes = uint8(unicode2native(char(message),'UTF-8'));
    header = uint8(bitget(uint32(numel(expectedBytes)),32:-1:1)).';
    expectedBits = [header;bytes_to_bits(expectedBytes)];
    after = typecast(attackedRead(:),'uint16');
    observedBits = uint8(bitget(after(1:numel(expectedBits)),1));
    rawBer = nnz(expectedBits ~= observedBits)/numel(expectedBits);
    try
        recovered = lsb_extract(attackedFile);
        recoveredBytes = numel(unicode2native(recovered,'UTF-8'));
        exact = isequal(recovered,char(message));
    catch
        recoveredBytes = NaN;
        exact = false;
    end
    attack = table(rawBer,recoveredBytes,exact, ...
        'VariableNames',{'RawPayloadBER','RecoveredMessageBytes','ExactRecovery'});
    writetable(attack,fullfile(outFolder,'attack_demo.csv'));
end

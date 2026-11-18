function run_tests()
%RUN_TESTS Small automatic checks for data hiding and failure conditions.
    base = fileparts(fileparts(mfilename('fullpath')));
    out = fullfile(base,'outputs','tests_tmp');
    if ~exist(out,'dir'), mkdir(out); end
    coverFile = fullfile(base,'data','cover_demo.wav');
    if ~exist(coverFile,'file'), generate_cover_audio(coverFile); end
    messages = {'A','Hello, DSP Lab!','1234567890', ...
                'This longer message tests the complete 32-bit header.', ...
                ['Caf' char(233)]}; % Non-ASCII UTF-8 byte-count check.
    for j = 1:numel(messages)
        stegoFile = fullfile(out,sprintf('test_%02d.wav',j));
        info = lsb_embed(coverFile,stegoFile,messages{j});
        [recovered,extra] = lsb_extract(stegoFile);
        q = quality_metrics(coverFile,stegoFile,messages{j},recovered);
        assert(strcmp(recovered,messages{j}),'Message round-trip mismatch.');
        assert(q.exactRecovery && q.messageBER==0, 'BER must be zero.');
        expectedBytes = numel(unicode2native(messages{j},'UTF-8'));
        assert(extra.messageBytes == expectedBytes, 'Header byte length incorrect.');
        assert(info.headerBits == 32,'Header must be 32 bits.');
        assert(q.changedSamples <= info.payloadBits,'Changed samples exceed payload bits.');
        assert(q.maxPcmDifference <= 1,'Each sample may change by only one PCM count.');
        [a,~] = audioread(coverFile,'native');
        [b,~] = audioread(stegoFile,'native');
        assert(isequal(a(info.payloadBits+1:end),b(info.payloadBits+1:end)), ...
            'Audio beyond embedded payload was changed.');
    end
    [original,Fs] = audioread(coverFile,'native');
    shortFile = fullfile(out,'too_short.wav');
    audiowrite(shortFile,original(1:80),Fs,'BitsPerSample',16);
    capacityCaught = false;
    try
        lsb_embed(shortFile,fullfile(out,'never_created.wav'),repmat('X',1,50));
    catch ME
        capacityCaught = strcmp(ME.identifier,'DSP:InsufficientCapacity');
    end
    assert(capacityCaught,'Capacity rejection did not work.');

    damagedFile = fullfile(out,'bad_header.wav');
    source = typecast(original(:),'uint16');
    source(1:32) = bitor(source(1:32),uint16(1));
    audiowrite(damagedFile,reshape(typecast(source(:),'int16'),size(original)), ...
        Fs,'BitsPerSample',16);
    damagedCaught = false;
    try
        lsb_extract(damagedFile);
    catch ME
        damagedCaught = strcmp(ME.identifier,'DSP:DamagedHeader');
    end
    assert(damagedCaught,'Corrupted length header must be detected.');

    % A correct DFT implementation satisfies Parseval's identity.
    a = rand(256,1); b = rand(256,1);
    e = fft(a-b);
    assert(abs(sum(abs(e).^2)/256-sum((a-b).^2))<1e-9, ...
        '1D DFT Parseval sanity check failed.');
    files = dir(fullfile(out,'*.wav'));
    for j = 1:numel(files), delete(fullfile(out,files(j).name)); end
    rmdir(out);
    fprintf('PASS: UTF-8 protocol structure, five round trips, capacity, corruption, and 1D DFT checks.\n');
end

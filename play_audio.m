try
    PsychDefaultSetup(2);
    InitializePsychSound(1);

    fs        = 48e3;
    nChannels = 2;
    pahandle  = PsychPortAudio('Open', [], 1, 1, fs, nChannels);

    % Build a 440-Hz stereo beep
    beep = MakeBeep(440, 0.3, fs);
    PsychPortAudio('FillBuffer', pahandle, [beep; beep]);

    %0: No need for an exact timestamp and want the script to continue without blocking.
    %1: Need for accurate audiovisual synchrony or want to log the true onset time.

    waitFlag = 0;
    % Start now, play once, wait until done
    PsychPortAudio('Start', pahandle, 1, 0, 0);

    % Give the ear a rest
    WaitSecs(0.2);

    PsychPortAudio('Close', pahandle);
catch ME
    PsychPortAudio('Close');   % Clean up if something goes wrong
    rethrow(ME);
end
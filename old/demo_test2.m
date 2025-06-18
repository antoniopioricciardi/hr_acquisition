% ---------------------------------------
% Psychtoolbox + audio: 5×"synch" & 5×"asynch" w/ 5 beeps
% ---------------------------------------

% Clear and setup
sca;
PsychDefaultSetup(2);
Screen('Preference','SkipSyncTests', 1);    % remove in real experiment!
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
grey  = white / 2;

% Open window
[win, winRect] = PsychImaging('OpenWindow', screenNumber, grey);
[xCenter, yCenter] = RectCenter(winRect);
Screen('TextSize', win, 40);

% ————— Setup sound —————
InitializePsychSound(1);                    % higher latency mode off
fs = 44100;                                 % sampling rate
nrChannels = 1;                             % mono
pahandle = PsychPortAudio('Open', [], 1, 1, fs, nrChannels);
beepDur = 0.05;                             % 50 ms noise burst
beepSamples = round(beepDur * fs);
noise = randn(1, beepSamples) * 0.1;        % white noise at low amplitude
PsychPortAudio('FillBuffer', pahandle, noise);

% Prepare trial list: 5 synch, 5 asynch
labels = [ repmat({'synch'},1,2), repmat({'asynch'},1,2) ];
labels = labels(randperm(numel(labels)));

% Define the escape key
escapeKey = KbName('ESCAPE');

% Main trial loop
for t = 1:numel(labels)
    
    % 1) Ready screen
    DrawFormattedText(win, 'Ready for the test', 'center', 'center', white);
    Screen('Flip', win);
    KbStrokeWait;   % wait for any key

    if keyCode(escapeKey)
        % Display exit message
        DrawFormattedText(win, "Goodbye", 'center', 'center', white);
        Screen('Flip', win);

        % Wait a second for the participant to read the message
        WaitSecs(1);

        break;
    end
    
    % 2) Show the label
    DrawFormattedText(win, labels{t}, 'center', 'center', white);
    Screen('Flip', win);
    
    % 3) Play 5 beeps, one per second
    for beepCount = 1:5
        PsychPortAudio('Start', pahandle, 1, 0, 1);  % play once, blocking until done
        WaitSecs(1 - beepDur);                       % wait until next second
    end
    
    % 4) Optional ITI
    Screen('Flip', win);
    WaitSecs(0.5);
end

% Clean up sound
PsychPortAudio('Close', pahandle);

% Final message
DrawFormattedText(win, 'Test complete!', 'center', 'center', white);
Screen('Flip', win);
WaitSecs(2);

% Clean up screen
sca;

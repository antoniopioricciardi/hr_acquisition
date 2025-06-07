% ---------------------------------------
% Example PTB script: 5x "synch", 5x "asynch"
% ---------------------------------------

% Clear and setup
sca;
PsychDefaultSetup(2);
Screen('Preference','SkipSyncTests', 1);    % for debugging only!
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
grey  = white / 2;

% Open window
[win, winRect] = PsychImaging('OpenWindow', screenNumber, grey);
[xCenter, yCenter] = RectCenter(winRect);
Screen('TextSize', win, 40);

% Prepare trial list: 5 of each, shuffled
labels = [ repmat({'synch'},1,5), repmat({'asynch'},1,5) ];
labels = labels(randperm(numel(labels)));

% Main loop
for t = 1:numel(labels)
    
    % 1) Ready screen
    DrawFormattedText(win, 'Ready for the test', 'center', 'center', white);
    Screen('Flip', win);
    KbStrokeWait;   % wait for any key
    
    % 2) Show the trial label
    DrawFormattedText(win, labels{t}, 'center', 'center', white);
    Screen('Flip', win);
    
    % 3) Pause so they can read (adjust duration as needed)
    WaitSecs(1.0);
    
    % 4) (Optionally) clear screen or show fixation
    Screen('Flip', win);
    WaitSecs(0.5);
end

% Done!
DrawFormattedText(win, 'Test complete!', 'center', 'center', white);
Screen('Flip', win);
WaitSecs(2);

% Clean up
sca;

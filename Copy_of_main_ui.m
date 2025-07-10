clear all
clc
%% ─── GLOBAL STATE ──────────────────────────────────────────────
global listener sessionActive peak_count peak_detected peak_delay_s,

num_demo_sessions = 2;
tests_per_delay = 2;

% these get reset on each run of main_ui, so you never inherit old state
sessionActive = false;
peak_count    = 0;
peak_detected = false;


%Example
%-------
d = labchart.getActiveDocument();


%persistent sound_y sound_Fs;

%if isempty(sound_y) || isempty(sound_Fs)
    % Fs = 44100; % Sampling frequency
    % t = 0:1/Fs:1; % Time vector for 1 second
    % f = 440; % Frequency of the sine wave (A4 note)
    % sound_y = sin(2 * pi * f * t); % Generate the sine wave
    % sound_Fs = Fs;
load gong.mat y Fs;
sound_y = y;
sound_Fs = Fs;
%end


%persistent heartbeat_y heartbeat_Fs;
heartbeat_Fs = 44100; % Sampling frequency
t = 0:1/heartbeat_Fs:0.5; % Time vector for 0.5 seconds

% Parameters for the thud
f = 200;%60; % Low frequency for the thud (Hz)
thud = sin(2 * pi * f * t); % Low-frequency sine wave

% Apply a Gaussian envelope for attack and decay
envelope = exp(-10 * t); % Exponential decay
heartbeat_y = thud .* envelope; % Modulate the sine wave with the envelope

% Normalize the signal to avoid clipping
heartbeat_y = heartbeat_y / max(abs(heartbeat_y));

dq = parallel.pool.DataQueue;       % your queue
peak_delay_s = 0.0;                          % 200 ms  ⇒ 0.20 s
%[wave,fs] = audioread('ding.wav');         % whatever sound you want

max_peaks = 10;

% now register the callback before any data ever arrives
%listener = afterEach(dq, @(chunk) syncPeakNaiveWithListener(...
%                          chunk, heartbeat_y, heartbeat_Fs));
listener = afterEach(dq, @(chunk) syncPeakPTB(chunk, heartbeat_y, heartbeat_Fs));

% Register callback – extra arguments are captured by the anonymous function
% TO BE FIXED, MATLAB SAYS INEFFICIENT
%global listener
%listener = afterEach(dq, @(chunk) syncPeakNaiveWithListener(chunk, delay_s, heartbeat_y, heartbeat_Fs, 10));
%Setup plotting
%------------------
clf %We'll setup for 3 channels ...
h1 = subplot(2,1,1);

%Initialize Streams
%------------------
fs = 1000; %frequency of sampling (sampling rate)
fs2 = 20000;
n_seconds_valid = 10;
s1 = labchart.streaming.ui_streamed_data2(fs,n_seconds_valid,'Channel 3',dq, 'h_axes',h1,'plot_options',{'Color','r'},'axis_width_seconds',5);


%Store whatever you want here. You can use this in the callback by
%accessing this property from the first input argument.
s1.user_data = 'hello!';

%Use this if you only want one channel
s1.register(d)
%global listener
%listener = afterEach(dq, @(chunk) syncPeakNaiveWithListener(chunk, delay_s, heartbeat_y, heartbeat_Fs, 10));

%To stop the events
%-------------------
%d.stopEvents()


% ONLY FOR DEVELOPMENT PURPOSES!
Screen('Preference', 'SkipSyncTests', 1);

try
    % Choosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);

    [width, height]=Screen('DisplaySize', screenNumber);
    
    window=Screen('OpenWindow', screenNumber,0,[],32,2);
    Screen('FillRect', window, [0, 0, 0]);
    Screen('TextFont',window, 'Courier New');
    Screen('TextStyle', window, 1);

    session_path = ui_directories(window);
    %sca;
    Screen('Flip', window);
    demo_done=false;
    while ~demo_done
        for i=1:num_demo_sessions
            if mod(i,2)==0
                peak_delay_s = 0.2;
                demo_session(window, '0.2');
            else
                peak_delay_s = 0.4;
                demo_session(window, '0.4');
            end
        end
        % draw your instructions
        Screen('FillRect', window, [0 0 0]);
        DrawFormattedText(window, 'Premi [R] per ripetere la demo, invio per andare avanti', 'center','center',[255 255 255]);
        Screen('Flip', window);

        % wait for a key press
        KbStrokeWait;                          % blocks until any key is down
        [~, ~, keyCode] = KbCheck;            % check which key
        keyPressed = KbName(find(keyCode));   % get name of the first key down
        
        % if multiple keys are returned, take the first
        if iscell(keyPressed)
            keyPressed = keyPressed{1};
        end
        
        % if it's NOT 'r', exit the loop
        if ~strcmpi(keyPressed, 'r')
            demo_done = true;
        end
    end

    %demo_session(window, dq, delay_s,  heartbeat_y, heartbeat_Fs, max_peaks);
    %clear peak_count;
    %delete(listener);
    %clear global listener;

    white_col = [255,255,255];
    Screen('Flip', window);
    DrawFormattedText(window, 'Premi [E] per uscire', 'right', [], white_col);
    DrawFormattedText(window, 'Ora cominceremo il test', 'center', 'center', white_col);
    Screen('Flip', window);
    KbStrokeWait;   % wait for any key

    % ────────────────────────────────────────────────────────────
    % Prepare randomized delays:
    delays = [repmat(0.2,tests_per_delay,1); repmat(0.4,tests_per_delay,1)];   % 20 of each
    delays = delays(randperm(numel(delays)));       % shuffle
    
    % Run 40 sessions with those delays in random order:
    for i = 1:numel(delays)
        peak_delay_s = delays(i);
        if peak_delay_s == 0.2
            result = session(window, 's');
        else
            result = session(window, 'a');
        end
        if result == 1
            disp('Risposta corretta.');
        else
            disp('Risposta errata.');
        end
        % Determine test type and correctness
        if peak_delay_s == 0.2
            test_type = 'sync';
        else
            test_type = 'async';
        end
        
        if result == 1
            correctness = 'correct';
        else
            correctness = 'wrong';
        end
        
        % Write result to CSV
        fid = fopen(session_path, 'a');  % Append mode
        fprintf(fid, '%d,%s,,%s,,,,,\n', i, test_type, correctness);
        fclose(fid);
    end
    % ────────────────────────────────────────────────────────────

    %out = session(window, 'a');
    if out == 1
        disp('User chose asynchronous as expected.');
    else
        disp('User chose something else.');
    end

   
    sca;
    delete(timerfind);     % stops the one-shot timers cleanly

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;

    psychrethrow(psychlasterror);
end % try..catch



% Then in your function:
function syncPeakNaiveWithListener3(new_data, delay, wave, sampling, max_peaks)
    persistent peak_detected peak_count
    global listener

    if isempty(peak_detected), peak_detected = false; end
    if isempty(peak_count), peak_count = 0; end

    if max_peaks > 0 && peak_count >= max_peaks
        fprintf('Reached max_peaks = %d. Deleting callback.\n', max_peaks);
        delete(listener);
        clear peak_count
        return
    end

    if any(new_data > 800)
        if ~peak_detected
            start_time = tic;
            fprintf('PEAK %d detected: %.3f\n', peak_count + 1, start_time);
            while toc(start_time) < delay
            end
            sound(wave, sampling);
            fprintf('Signal: %.3f\n', toc(start_time));
            peak_detected = true;
            peak_count = peak_count + 1;
        end
    else
        peak_detected = false;
    end
end



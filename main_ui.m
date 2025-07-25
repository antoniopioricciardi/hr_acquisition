clear all
clc
%% ─── GLOBAL STATE ──────────────────────────────────────────────
global listener sessionActive peak_count peak_detected peak_delay_s pahandles,
num_audio_handles = 10;
PsychDefaultSetup(2);

% load config parameters
cfg = config();
num_demo_sessions = cfg.num_demo_sessions;
tests_per_delay = cfg.tests_per_delay;
max_peaks = cfg.max_peaks;
sound_pitch = cfg.sound_pitch; % frequency for the thud (Hz)
sessionActive = true;
pause(0.5);

% these get reset on each run of main_ui, so you never inherit old state
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
%load gong.mat y Fs;
%sound_y = y;
%sound_Fs = Fs;
%end


[heartbeat_y, heartbeat_Fs] = create_beep(sound_pitch);

dq = parallel.pool.DataQueue;       % your queue
peak_delay_s = 0.0;                          % 200 ms  ⇒ 0.20 s
%[wave,fs] = audioread('ding.wav');         % whatever sound you want

% now register the callback before any data ever arrives
%listener = afterEach(dq, @(chunk) syncPeakNaiveWithListener(...
%                          chunk, heartbeat_y, heartbeat_Fs));
% Initialize PsychPortAudio once
initializePsychAudioVector(heartbeat_y, heartbeat_Fs, num_audio_handles);
global player
%player = audioplayer(heartbeat_y, heartbeat_Fs); 
listener = afterEach(dq, @(chunk) syncPeakPTB(chunk, heartbeat_y, heartbeat_Fs));
sessionActive = false;

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
n_seconds_valid = 2;
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

%InitializePsychSound(1);
%nChannels = 2;
%pahandle  = PsychPortAudio('Open', [], 1, 1, fs, nChannels);


% ONLY FOR DEVELOPMENT PURPOSES!
Screen('Preference', 'SkipSyncTests', 1); %  THIS SHOULD BE 0 FOR REAL TESTS!


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

    [session_path, to_exit] = ui_directories(window);
    %sca;
    if to_exit
        sca;
        return
    end
    Screen('Flip', window);

    % ---- DEMO PHASE ---- %
%     demo_done=false;
%     while ~demo_done
%         for i=1:num_demo_sessions
%             % draw your instructions
%             Screen('FillRect', window, [0 0 0]);
%             DrawFormattedText(window, 'SESSIONE DI PROVA, PREMI UN TASTO PER COMINCIARE', 'center','center',[255 255 255]);
%             Screen('Flip', window);
%             KbStrokeWait;
% 
%             if mod(i,2)==0
%                 peak_delay_s = 0.2;
%                 [result, answer, answer_elapsed_time, session_elapsed_time, session_start_time_abs, session_end_time_abs] = session(window, 's');
%                 %session(window, '0.2');
%             else
%                 peak_delay_s = 0.4;
%                 [result, answer, answer_elapsed_time, session_elapsed_time, session_start_time_abs, session_end_time_abs] = session(window, 'a');
%                 %session(window, '0.4');
%             end
%             if result == 1
%                 Screen('FillRect', window, [0 0 0]);
%                 DrawFormattedText(window, 'Risposta corretta. Premi un tasto per continuare', 'center','center',[255 255 255]);
%                 Screen('Flip', window);
%                 KbStrokeWait;
%                 disp('Risposta corretta.');
%             else
%                 Screen('FillRect', window, [0 0 0]);
%                 DrawFormattedText(window, 'Risposta errata. Premi un tasto per continuare', 'center','center',[255 255 255]);
%                 Screen('Flip', window);
%                 KbStrokeWait;
%                 disp('Risposta errata.');
%             end
%         end
%         % draw your instructions
%         Screen('FillRect', window, [0 0 0]);
%         DrawFormattedText(window, 'Premi [R] per ripetere la demo, invio per andare avanti', 'center','center',[255 255 255]);
%         Screen('Flip', window);
% 
%         % wait for a key press
%         KbStrokeWait;                          % blocks until any key is down
%         [~, ~, keyCode] = KbCheck;            % check which key
%         keyPressed = KbName(find(keyCode));   % get name of the first key down
%         
%         % if multiple keys are returned, take the first
%         if iscell(keyPressed)
%             keyPressed = keyPressed{1};
%         end
%         
%         % if it's NOT 'r', exit the loop
%         if ~strcmpi(keyPressed, 'r')
%             demo_done = true;
%         else
%             demo_done = false;
%         end
%         
%     end

    % ---- DEMO PHASE DONE ---- %
    
    % ---- TEST PHASE ---- %
    test_start_time = tic;

    white_col = [255,255,255];
    Screen('Flip', window);
    DrawFormattedText(window, 'Premi [E] per uscire', 'right', [], white_col);
    DrawFormattedText(window, 'Ora cominceremo il test', 'center', 'center', white_col);
    Screen('Flip', window);
    KbStrokeWait;   % wait for any key

    % ────────────────────────────────────────────────────────────
    % Prepare randomized delays:
    delays = [repmat(cfg.peak_delay_synch,tests_per_delay,1); repmat(cfg.peak_delay_asynch,tests_per_delay,1)];   % 20 of each
    delays = delays(randperm(numel(delays)));       % shuffle
    
    % Run 40 sessions with those delays in random order:
    for i = 1:numel(delays)
        peak_delay_s = delays(i);
        if peak_delay_s == 0.2
            [result, answer, answer_elapsed_time, session_elapsed_time, session_start_time_abs, session_end_time_abs] = session(window, 's');
        else
            [result, answer, answer_elapsed_time, session_elapsed_time, session_start_time_abs, session_end_time_abs] = session(window, 'a');
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
        test_end_time = toc(test_start_time);
        %formatted_test_end_time = seconds(test_end_time,'Format','hh:mm:ss');
        formatted_test_end_time    = seconds(test_end_time); % a duration object
        formatted_test_end_time.Format = 'hh:mm:ss';
        % ---- TEST PHASE DONE ---- %
        
        % ---- SAVE RESULTS TO FILE---- %
        answer_elapsed_time = round(answer_elapsed_time, 2);
        session_elapsed_time = round(session_elapsed_time, 2);

        % Write result to CSV
        fid = fopen(session_path, 'a');  % Append mode
        %fprintf(fid, '%d,%s,%s,%s,%s,%d,%d,%d,%d\n', i, test_type, result, answer, correctness, answer_elapsed_time, session_elapsed_time, session_start_time_abs, session_end_time_abs);
        
        % convert datetimes to strings
        tstart_str = char(session_start_time_abs);   % e.g. '14:32:07'
        tend_str = char(session_end_time_abs);     % e.g. '14:32:12'
        formatted_test_end_time_str = char(formatted_test_end_time);
        %tempo trascorso (s),ora inizio task, ora fine task, tempo totale trascorso'
        % now fprintf with matching specifiers:
        fprintf(fid, ...
            '%d,%s,%s,%s,%.2f,%.2f,%s,%s,%s\n', ...
            i, ...
            test_type, ...
            answer, ...
            correctness, ...
            answer_elapsed_time, ...
            session_elapsed_time, ...
            tstart_str, ...
            tend_str, ...
            formatted_test_end_time_str);
        
        fclose(fid);

        % ---- EXIT LOOP ---- 
        exitLoop = false;

        instr = 'Premi invio per continuare, "E" per uscire';
        DrawFormattedText(window, instr, 'center','center',[255 255 255]);
        Screen('Flip', window);

        % Flush any leftover keypresses
        KbReleaseWait;  

        % Wait for a key
        while true
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                % Check if they hit 'E' (case‑insensitive)
                if keyCode(KbName('e')) || keyCode(KbName('E'))
                    exitLoop = true;
                end
                break;
            end
        end

        if exitLoop
            disp('User requested exit. Stopping loop.');
            break;   % out of the for‐loop
        end
        % ---- END EXIT LOOP ----
    end
    % ────────────────────────────────────────────────────────────
   
    % sca;
    % delete(timerfind);     % stops the one-shot timers cleanly
    % cleanupPsychAudioVector(num_audio_handles)
    cleanup_routine();
catch
    % cleanupPsychAudioVector(num_audio_handles)
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    % sca;
    cleanup_routine();
    psychrethrow(psychlasterror);
end % try..catch


function cleanup_routine()
    sca;
    delete(timerfind);     % stops the one-shot timers cleanly
    cleanupPsychAudioVector(num_audio_handles)

end


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

% Initialization function (call once at startup)
function initializePsychAudioVector(wave, sampling, num_handles)
    global pahandles
    %fs = 44100;               % Sampling frequency
    nrChannels = 1;
    % Fill all handles with the same 440 Hz beep (can be different if needed)
    %beep = MakeBeep(200, 0.1, fs);
    %buffer = [beep; beep];  % stereo

    %[wave, sampling] = create_beep()


    % Initialize PsychPortAudio
    InitializePsychSound(1); % 1 = push hard for low latency
    
    % Ensure wave is properly formatted
    % PsychPortAudio expects: rows = channels, columns = samples
    % Your heartbeat_y should already be a row vector (1 x N)
    if size(wave, 1) > size(wave, 2)
        wave = wave'; % Convert column vector to row vector if needed
    end
    
    nchannels = size(wave, 1); % Should be 1 for mono
    nsamples = size(wave, 2);  % Should be your actual sample count
    
    % Create 5 handles (audio devices) for mono playback
    % Parameters: deviceid, mode, reqlatencyclass, freq, nchannels
    pahandles = zeros(1, num_handles);
    for i = 1:num_handles
        pahandles(i) = PsychPortAudio('Open', [], 1, 1, sampling, nrChannels);
        PsychPortAudio('Volume', pahandles(i), 1);
        PsychPortAudio('FillBuffer', pahandles(i), wave);
    end
    
    % Set volume (optional)
    %PsychPortAudio('Volume', pahandle, 1);
    
    fprintf('PsychPortAudio initialized:\n');
    fprintf('  Sampling rate: %d Hz\n', sampling);
    fprintf('  Channels: %d\n', nchannels);
    fprintf('  Samples: %d\n', nsamples);
    fprintf('  Duration: %.3f s\n', nsamples/sampling);
end

% Cleanup function (call when done)
function cleanupPsychAudioVector(num_handles)
    global pahandles
    
    for  i = 1:num_handles
        if ~isempty(pahandles)
            PsychPortAudio('Close', pahandles(i));
            %pahandle = [];
        end
    end
end



% Initialization function (call once at startup)
function initializePsychAudio(wave, sampling)
    global pahandle
    
    % Initialize PsychPortAudio
    InitializePsychSound(1); % 1 = push hard for low latency
    
    % Ensure wave is properly formatted
    % PsychPortAudio expects: rows = channels, columns = samples
    % Your heartbeat_y should already be a row vector (1 x N)
    if size(wave, 1) > size(wave, 2)
        wave = wave'; % Convert column vector to row vector if needed
    end
    
    nchannels = size(wave, 1); % Should be 1 for mono
    nsamples = size(wave, 2);  % Should be your actual sample count
    
    % Open audio device for mono playback
    % Parameters: deviceid, mode, reqlatencyclass, freq, nchannels
    pahandle = PsychPortAudio('Open', [], 1, 1, sampling, 1); % Force mono (1 channel)
    
    % Set volume (optional)
    PsychPortAudio('Volume', pahandle, 1);
    
    fprintf('PsychPortAudio initialized:\n');
    fprintf('  Sampling rate: %d Hz\n', sampling);
    fprintf('  Channels: %d\n', nchannels);
    fprintf('  Samples: %d\n', nsamples);
    fprintf('  Duration: %.3f s\n', nsamples/sampling);
end

% Cleanup function (call when done)
function cleanupPsychAudio()
    global pahandle
    
    if ~isempty(pahandle)
        PsychPortAudio('Close', pahandle);
        pahandle = [];
    end
end


function [heartbeat_y, heartbeat_Fs] = create_beep(sound_pitch)
    %persistent heartbeat_y heartbeat_Fs;
    sound_length_t = 0.1; % length of the sound (in seconds)
    heartbeat_Fs = 44100; % Sampling frequency
    t = 0:1/heartbeat_Fs:sound_length_t; % Time vector for sound_length_t seconds
    
    % Parameters for the thud
    %sound_pitch = cfg.sound_pitch; % frequency for the thud (Hz)
    %f = 200;%60; % Low frequency for the thud (Hz)
    thud = sin(2 * pi * sound_pitch * t); % Low-frequency sine wave
    
    % Apply a Gaussian envelope for attack and decay
    envelope = exp(-10 * t); % Exponential decay
    heartbeat_y = thud .* envelope; % Modulate the sine wave with the envelope
    
    % Normalize the signal to avoid clipping
    heartbeat_y = heartbeat_y / max(abs(heartbeat_y));
end
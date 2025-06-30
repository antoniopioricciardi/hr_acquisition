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



dq        = parallel.pool.DataQueue;       % your queue
delay_s   = 0.20;                          % 200 ms  ⇒ 0.20 s
%[wave,fs] = audioread('ding.wav');         % whatever sound you want

% Register callback – extra arguments are captured by the anonymous function
%afterEach(dq, @(chunk) syncPeakNaive(chunk, delay_s,  heartbeat_y, heartbeat_Fs));

cb        = buildPeakCallback(0.20,heartbeat_y, heartbeat_Fs);
afterEach(dq, cb);

%dq = parallel.pool.DataQueue;                 % ① an async conduit
%afterEach(dq, @gotSegment);                  % ② what to do with new data
%Setup plotting
%------------------
clf %We'll setup for 3 channels ...
h1 = subplot(2,1,1);
%h2 = subplot(2,1,2);
%h3 = subplot(3,1,3);

%Initialize Streams
%------------------
fs = 1000; %frequency of sampling (sampling rate)
fs2 = 20000;
n_seconds_valid = 10;
s1 = labchart.streaming.ui_streamed_data2(fs,n_seconds_valid,'Channel 3','h_axes',h1,'plot_options',{'Color','r'},'axis_width_seconds',5);

s1.callback = @labchart.streaming.callback_examples.nValidSamples;

%s1.callback = @labchart.streaming.callback_examples.myStreamingCallback;
%s1.callback = @labchart.streaming.callback_examples.store_new_data; % accumulate segments for offline use
% s1.callback = @labchart.streaming.callback_examples.pushToQueue;
s1.callback = @(obj,~) ...
    labchart.streaming.callback_examples.pushToQueue(obj, dq);
%s1.callback = @(obj,~)labchart.streaming.callback_examples.pushToQueue(obj, dq);   % <- only one line!
%s1.callback = @labchart.streaming.callback_examples.myStreamingCallback;
%Alternatively
%s1.callback = @labchart.streaming.callback_examples.averageSamplesAddComment;

%Store whatever you want here. You can use this in the callback by
%accessing this property from the first input argument.
%s1.user_data = 'hello!';

%Initialize user data buffer used by the callback

%Use this if you only want one channel
s1.register(d)



%To stop the events
%-------------------
%d.stopEvents()
function gotSegment(seg)
    persistent buf n
    if isempty(buf)
        buf = zeros(1e7,1,'single');   % pre-allocate ~10 M samples
        n   = 0;                       % write pointer
    end
    seg = seg(:);               % N×1
    k   = numel(seg);
    if n+k > numel(buf)         % auto-grow if needed
        buf = [buf ; zeros(round(1.5*numel(buf)),1,'like',buf)];
    end
    buf(n+1:n+k) = seg;         % write in place
    n = n+k;
    disp(['seg size: ' mat2str(size(seg))])
    seg
end


function syncPeakNaive(new_data, delay, wave, sampling)
    % Print "PEAK" exactly 200ms after detecting a peak
    persistent peak_detected

    % peak_detected is to avoid finding peaks in two consecutive buffers
    if isempty(peak_detected)
        peak_detected = false;
    end

    % Check if any value in new_data exceeds 800
    if any(new_data > 800)
        if ~peak_detected
            start_time = tic;
            fprintf('PEAK detected: %.3f\n', start_time)%, 'HH:MM:SS.FFF'));
            % Wait for delay ms (usually 200 or 500 ms)
            % pause(delay);
            while toc(start_time) < delay
                % Busy-waiting until the delay time is reached
            end
            sound(wave, sampling);
            % Print "Signal" and time elapsed after delay
            fprintf('Signal: %.3f\n', toc(start_time))
            peak_detected = true;
        end
    else
        peak_detected = false;
    end
end

function cb = buildPeakCallback(delay_s, wave, fs)
% buildPeakCallback  Return a one-argument function suitable for afterEach.
%
%   cb = buildPeakCallback(0.20, wave, fs);
%   afterEach(dq, cb);

    peakPending  = false;       % state carried inside the closure
    tDelay       = timer( ...
                       'ExecutionMode','singleShot', ...
                       'TimerFcn',@(~,~) playAndPrint(), ...
                       'StartDelay',delay_s);

    cb = @callback;             % handle returned to caller
    % ---------- nested functions ----------
    function callback(new_data) %#ok<INUSD>
        if any(new_data > 800) && ~peakPending
            peakPending = true;
            fprintf('PEAK detected  @ %.3f s\n', now*86400);  % crude timestamp
            start(tDelay);       % fire the one-shot timer
        elseif all(new_data <= 800)
            peakPending = false; % reset detector
        end
    end

    function playAndPrint()
        sound(wave,fs);
        fprintf('Signal (%.0f ms later)\n', delay_s*1000);
        peakPending = false;
    end
end


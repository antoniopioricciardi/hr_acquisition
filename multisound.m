InitializePsychSound(1);
fs = 44100;               % Sampling frequency
nrChannels = 2;

% Create 5 handles
num_handles = 5;
pahandles = zeros(1, num_handles);
for i = 1:num_handles
    pahandles(i) = PsychPortAudio('Open', [], 1, 1, fs, nrChannels);
end

% Fill all handles with the same 440 Hz beep (can be different if needed)
beep = MakeBeep(440, 0.5, fs);
buffer = [beep; beep];  % stereo
for i = 1:num_handles
    PsychPortAudio('FillBuffer', pahandles(i), buffer);
end



% Example use: play 3 sounds spaced 0.3s apart
for i = 1:3
    idx = getFreeHandle(pahandles);
    if idx ~= -1
        fprintf('Using pahandle #%d\n', idx);
        PsychPortAudio('Start', pahandles(idx), 1, GetSecs + 0.1);
    else
        warning('No free audio handle available!');
    end
    pause(0.3);
end

% Wait for all to finish
WaitSecs(5);

% Close all handles
for i = 1:num_handles
    PsychPortAudio('Close', pahandles(i));
end


% Function to find the first free handle
function handle_index = getFreeHandle(pahandles)
    handle_index = -1;
    for i = 1:length(pahandles)
        status = PsychPortAudio('GetStatus', pahandles(i));
        if ~status.Active
            handle_index = i;
            return;
        end
    end
end
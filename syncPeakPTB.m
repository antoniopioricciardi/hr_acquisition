function syncPeakPTB(new_data, wave, sampling)
    global listener sessionActive peak_detected peak_count peak_delay_s 
    global pahandles % PsychPortAudio handle
    stop_peak = 1;
    if sessionActive
        %–– simple edge-detect on threshold
        if any(new_data > 800)
            start_peak = tic;
            if ~peak_detected && peak_count < 10 && stop_peak > 0.1
                start_time = tic;
                fprintf('PEAK detected: %.3f\n', start_time);
                %fprintf('PEAK detected at: %s\n', datestr(start_time, 'HH:MM:SS.FFF'));

                % Calculate when to play audio (current time + delay)
                when_to_play = GetSecs + peak_delay_s;
               
                % get the first free audio handle
                idx = getFreeHandle(pahandles);
                % play sound with the specified delay
                if idx ~= -1
                    fprintf('Using pahandle #%d\n', idx);
                    PsychPortAudio('Start', pahandles(idx), 1, when_to_play);
                    % WaitSecs(0.01); %should avoid overplaying (Really?)
                else
                    warning('No free audio handle available!');
                end
                    %pause(0.3);
                %end
                
                % Wait until the scheduled time has passed
                %while GetSecs < when_to_play
                    % Brief pause to avoid busy waiting
                %    WaitSecs(0.001);
                %end
                
                fprintf('Signal: %.3f\n', toc(start_time));
                peak_detected = true;
                peak_count = peak_count + 1;
                fprintf('Beat #%d\n', peak_count);
                fprintf('Delay: %.3f s\n', peak_delay_s);
            end
            % use this to avoid overplaying because the peak is in two
            % consecutive buffers
            stop_peak = toc(start_peak);
        else
            peak_detected = false;
        end
    end
end

% Function to find the first free handle
function handle_index = getFreeHandle(pahandles)
    handle_index = -1;
    for i = 1:length(pahandles)
        status = PsychPortAudio('GetStatus', pahandles(i));
        if ~status.State
            handle_index = i;
            return;
        end
    end
end
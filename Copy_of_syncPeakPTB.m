function syncPeakPTB(new_data, wave, sampling)
    global listener sessionActive peak_detected peak_count peak_delay_s 
    global pahandle % PsychPortAudio handle
    
    if sessionActive
        %–– simple edge-detect on threshold
        if any(new_data > 800)
            if ~peak_detected
                start_time = tic;
                fprintf('PEAK detected: %.3f\n', start_time);
                
                % Calculate when to play audio (current time + delay)
                when_to_play = GetSecs + peak_delay_s;
                
                % Your heartbeat_y should already be properly formatted as row vector
                % Just ensure it's the right shape (1 x N)
                % audio_data = wave;
%                 if size(audio_data, 1) > size(audio_data, 2)
%                     audio_data = audio_data'; % Convert column to row if needed
%                 end
                
                % Fill audio buffer
                % PsychPortAudio('FillBuffer', pahandle, audio_data);
                
                % Schedule playback at precise time
                PsychPortAudio('Start', pahandle, 1, when_to_play);
                
                % Wait until the scheduled time has passed
                while GetSecs < when_to_play
                    % Brief pause to avoid busy waiting
                    WaitSecs(0.001);
                end
                
                fprintf('Signal: %.3f\n', toc(start_time));
                peak_detected = true;
                peak_count = peak_count + 1;
                fprintf('Beat #%d\n', peak_count);
                fprintf('Delay: %.3f s\n', peak_delay_s);
            end
        else
            peak_detected = false;
        end
    end
end
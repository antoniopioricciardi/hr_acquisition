function syncPeakPTB(new_data, wave, sampling)
    global listener sessionActive peak_detected peak_count peak_delay_s player
    
    if sessionActive
        %–– simple edge-detect on threshold
        if any(new_data > 800)
            if ~peak_detected
                start_time = tic;
                fprintf('PEAK detected: %.3f\n', start_time)%, 'HH:MM:SS.FFF'));
                % Wait for delay ms (usually 200 or 500 ms)
                % pause(delay);
%                 while toc(start_time) < peak_delay_s
%                     % Busy-waiting until the delay time is reached
%                 end
                % 86400 is the seconds in a day
                target_time = now + peak_delay_s/86400; % Convert to datenum

                % PLAY IMMEDIATELY
                play(player, target_time);

                %playS()
                fprintf('Signal: %.3f\n', toc(start_time))
                peak_detected = true;
                peak_count    = peak_count + 1;
                fprintf('Beat #%d\n', peak_count);
                fprintf('Beat #%d\n', peak_delay_s);
            end
        else
            peak_detected = false;
        end
    end
end


% function syncPeakPTB(new_data, wave, sampling)
%     global listener sessionActive peak_detected peak_count peak_delay_s 
%     
%     if sessionActive
%         %–– simple edge-detect on threshold
%         if any(new_data > 800)
%             if ~peak_detected
%                 start_time = tic;
%                 fprintf('PEAK detected: %.3f\n', start_time)%, 'HH:MM:SS.FFF'));
%                 % Wait for delay ms (usually 200 or 500 ms)
%                 % pause(delay);
%                 while toc(start_time) < peak_delay_s
%                     % Busy-waiting until the delay time is reached
%                 end
%                 % PLAY IMMEDIATELY
%                 sound(wave, sampling);
% 
%                 %playS()
%                 fprintf('Signal: %.3f\n', toc(start_time))
%                 peak_detected = true;
%                 peak_count    = peak_count + 1;
%                 fprintf('Beat #%d\n', peak_count);
%                 fprintf('Beat #%d\n', peak_delay_s);
%             end
%         else
%             peak_detected = false;
%         end
%     end
% end


function playS()
    global pahandle
    try
        fs        = 48e3;
    
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
    
        
    catch ME
        PsychPortAudio('Close');   % Clean up if something goes wrong
        rethrow(ME);
    end
end
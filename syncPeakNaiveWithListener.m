function syncPeakNaiveWithListener(new_data, wave, sampling)
    global listener sessionActive peak_detected peak_count peak_delay_s

    %–– only act while a session is running
    %if ~sessionActive
        %return
    %end

    %–– once we hit max_peaks, tear down the listener and stop
    %if peak_count >= max_peaks
        %fprintf('Reached %d peaks – deleting callback.\n', max_peaks);
        %delete(listener);
    %    return
    %end

    if sessionActive
        %–– simple edge-detect on threshold
        if any(new_data > 800)
            if ~peak_detected
                start_time = tic;
                fprintf('PEAK detected: %.3f\n', start_time)%, 'HH:MM:SS.FFF'));
                % Wait for delay ms (usually 200 or 500 ms)
                % pause(delay);
                while toc(start_time) < peak_delay_s
                    % Busy-waiting until the delay time is reached
                end
                % PLAY IMMEDIATELY
                sound(wave, sampling);
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

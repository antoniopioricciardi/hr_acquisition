function addDataPeak(obj,h_doc)
%
%   Inputs
%   ------
%   h_doc : labchart.document

%Note, we wrap everything in a try/catch so that
%if this is broken it only throws 1 error then
%stops running ...

persistent sound_y sound_Fs;

if isempty(sound_y) || isempty(sound_Fs)
    % Fs = 44100; % Sampling frequency
    % t = 0:1/Fs:1; % Time vector for 1 second
    % f = 440; % Frequency of the sine wave (A4 note)
    % sound_y = sin(2 * pi * f * t); % Generate the sine wave
    % sound_Fs = Fs;
    load gong.mat y Fs;
    sound_y = y;
    sound_Fs = Fs;
end


persistent heartbeat_y heartbeat_Fs;
heartbeat_Fs = 44100; % Sampling frequency
t = 0:1/heartbeat_Fs:0.5; % Time vector for 0.5 seconds

% Parameters for the thud
f = 60; % Low frequency for the thud (Hz)
thud = sin(2 * pi * f * t); % Low-frequency sine wave

% Apply a Gaussian envelope for attack and decay
envelope = exp(-10 * t); % Exponential decay
heartbeat_y = thud .* envelope; % Modulate the sine wave with the envelope

% Normalize the signal to avoid clipping
heartbeat_y = heartbeat_y / max(abs(heartbeat_y));

try
    if ~obj.error_thrown
        
        
        %Performance Logging
        %------------------------------------------------
        obj.n_add_data_calls = obj.n_add_data_calls + 1;
        
        obj.perf_I = obj.perf_I + 1;
        if obj.perf_I > 100
            obj.perf_I = 1;
        end

        if ~isempty(obj.h_tic_start)
            obj.ms_since_last_callback(obj.perf_I) = 1000*(toc(obj.h_tic_start));
        end
        
        obj.h_tic_start = tic;
        
        %Record change handling
        %----------------------
        %This makes it easier for the user to use ...
        if obj.auto_detect_record_change
            %This fails periodically, why????????
            %What do we want to do in this case ????
            if h_doc.current_record ~= obj.current_record
                obj.reset();
            end
        end
        
        if ~obj.block_initialized
            is_init_call = true;
            obj.block_initialized = true;
            obj.h_tic_start = tic;
            obj.current_record = h_doc.current_record;
            obj.ticks_per_second = 1/h_doc.getSecondsPerTick(obj.current_record);
            
            %name resolution
            %--------------------------------
            if ischar(obj.chan_index_or_name)
                I = find(strcmpi(h_doc.channel_names,obj.chan_index_or_name));
                if isempty(I)
                    error('unable to find specified channel for streaming')
                end
                obj.chan_index = I;
            end
            
            %step/hold options
            %--------------------------------------------------
            if obj.remove_sample_hold
                %verify decimation amount
                temp = obj.ticks_per_second/obj.fs;
                if temp ~= round(temp)
                    %Basically this means the user specified
                    %fs wrong because
                    error('unable to find valid decimation step size')
                end
                obj.decimation_step_size = temp;
                obj.data_dt = 1/obj.fs;
            else
                obj.decimation_step_size = 1;
                obj.data_dt = 1/obj.ticks_per_second;
            end
            
            %Buffer initialization
            %--------------------------------------------------
            obj.n_samples_keep_valid = ceil(obj.n_seconds_keep_valid/obj.data_dt);
            obj.buffer_size = ceil(obj.n_samples_keep_valid*obj.buffer_muliplier);
            obj.data = zeros(1,obj.buffer_size);
            obj.last_valid_I = 0;
            
            %Plotting
            %------------------------------------
            if isvalid(obj.h_axes)
                obj.h_line = animatedline(...
                    'MaximumNumPoints',obj.buffer_size,...
                    'Parent',obj.h_axes,...
                    obj.plot_options{:});
            end
            
            %Where are we in time??? - how far back do we go???
            %------------------------------------------------------
            n_ticks_current_record = h_doc.getRecordLengthInTicks(obj.current_record);
            n_samples_available = n_ticks_current_record/obj.decimation_step_size;
            
            if n_samples_available > obj.n_samples_keep_valid
                n_samples_grab = obj.n_samples_keep_valid*obj.decimation_step_size;
                start_I = n_ticks_current_record-n_samples_grab+1;
            else
                n_samples_grab = n_ticks_current_record;
                start_I = 1;
            end
            new_data = h__getData(h_doc,obj,start_I,n_samples_grab);
        else %already initialized
            is_init_call = false;
            new_data = h__getData(h_doc,obj,obj.last_grab_end+1,-1);
        end
        
        % Check for peak in new_data
        % checkForPeak(new_data);
        % avgbpm(new_data);
        delay = 0.5;
        syncPeakNaive(new_data, delay, heartbeat_y, heartbeat_Fs);

        %if 
        
        %At this point we are initialized and have 'new_data'
        %as well as an updated state
        
        %Remove held samples ...
        %-------------------------------------------
        if obj.decimation_step_size ~= 1
            new_data = new_data(1:obj.decimation_step_size:end);
        end
        
        obj.n_samples_added(obj.perf_I) = length(new_data);
        
        %Processing before plotting
        %----------------------------------------------------------
        %   Example: labchart.streaming.processors.butterworth_filter
        
        %NOTE: Due to use of data_dt we can't downsample here (otherwise we
        %would need to support updating the data_dt property)
        %... Eventually we should support this ...
        if ~isempty(obj.new_data_processor)
            temp_data = new_data; %for debugging
            new_data = obj.new_data_processor(temp_data,is_init_call);
        end
        
        %Plotting
        % %----------------------------------------------------------
        % if isvalid(obj.h_line)
        %     x1 = obj.last_grab_start/obj.ticks_per_second;
        %     x2 = obj.last_grab_end/obj.ticks_per_second;
        %     x = x1:obj.data_dt:x2;
        %     addpoints(obj.h_line,x,new_data);
        %     if ~isempty(obj.axis_width_seconds)
        %         set(obj.h_axes,'xlim',[x2-obj.axis_width_seconds x2])
        %     end
        % end
        
        % %Processing after plotting
        % %----------------------------------------------------------
        % if ~isempty(obj.new_data_processor2)
        %     temp_data = new_data; %for debugging
        %     new_data = obj.new_data_processor2(temp_data,is_init_call);
        % end
        
        % %Adding data to buffer for analysis
        % %----------------------------------------------------------
        % if length(new_data) > obj.n_samples_keep_valid
        %     obj.data = new_data(end-obj.n_samples_keep_valid+1:end);
        %     obj.last_valid_I = length(obj.data);
        % elseif length(new_data) + obj.last_valid_I > obj.buffer_size
        %     obj.n_buffer_resets = obj.n_buffer_resets + 1;
        %     %Example:
        %     %keep 20 valid
        %     %95 - last_valid_I
        %     %we now have 13 new samples
        %     %
        %     %   13 new samples go in from 20-13+1 to 20
        %     %
        %     start1 = obj.n_samples_keep_valid-length(new_data)+1;
        %     end1 = obj.n_samples_keep_valid;
        %     %don't want to pollute data before shuffling
        %     %obj.data(start1:end1) = new_data;
            
        %     %
        %     %   We still need 7 samples, grab from 95 backwards
        %     %           95-n_samples_grab+1:95
        %     %
        %     n_samples_grab = obj.n_samples_keep_valid-length(new_data);
        %     start2 = obj.last_valid_I-n_samples_grab+1;
        %     end2 = obj.last_valid_I;
            
        %     obj.data(1:n_samples_grab) = obj.data(start2:end2);
        %     %do this after internal shuffling;
        %     obj.data(start1:end1) = new_data;
            
        %     obj.last_valid_I = obj.n_samples_keep_valid;
        % else
        %     obj.n_simple_adds = obj.n_simple_adds + 1;
        %     start_I = obj.last_valid_I+1;
        %     end_I = obj.last_valid_I+length(new_data);
        %     obj.data(start_I:end_I) = new_data;
        %     obj.last_valid_I = end_I;
        end
        
        obj.new_data = new_data;
        
        
        obj.n_seconds_valid = obj.last_valid_I*obj.data_dt;
        
        %Callback ...
        %----------------------
        if ~isempty(obj.callback)
            if ~obj.callback_only_when_ready || ...
                    obj.n_seconds_valid >= obj.n_seconds_keep_valid
                obj.callback(obj,h_doc);
            end
        end
        
        %Performance logging
        %-------------------
        obj.ms_per_callback(obj.perf_I) = 1000*toc(obj.h_tic_start);
    end
catch ME
    if ~obj.error_thrown
        obj.error_thrown = true; %Only throw this once
        fprintf(2,'error in addData callback, see debug_ME variable in base workspace\n')
        assignin('base','debug_ME',ME)
        assignin('base','debug_streaming',obj)
        obj.error_ME = ME;
    end
end
end

function data_vector = h__getData(doc,obj,start_I,n_samples)
AS_DOUBLE = 1;
channel_number_1b = obj.chan_index;
block_number_1b = obj.current_record;

%Note, we're bypassing the doc method call and calling the underlying
%library directly to avoid the overhead ...
data_vector = doc.h.GetChannelData(...
    AS_DOUBLE,...
    channel_number_1b,...
    block_number_1b,...
    start_I,...
    n_samples);

obj.last_grab_start = start_I;
n_samples2 = length(data_vector);
%TODO: validate length is what we expect if n_samples is not -1
%-1 means grab all
obj.last_grab_end = start_I + n_samples2-1;
end


% function checkForPeak(new_data)
%     % Check if any value in new_data exceeds 600
%     if any(new_data > 600)
%         % also display the current time in seconds to the millisecond, no need to display the entire new_data
%         fprintf('PEAK: %s \n', datestr(now, 'HH:MM:SS.FFF'));
%     else
%         % display first 5 entries if no peak. First check whether new_data is not empty
%         if isempty(new_data)
%             fprintf('new_data is empty %s \n', datestr(now, 'HH:MM:SS.FFF'));
%         else
%             fprintf('No peak: %s \n', datestr(now, 'HH:MM:SS.FFF'));
%         end
%     end
% end

function syncPeakNaive(new_data, delay, wave, sampling)
    % Print "PEAK" exactly 200ms after detecting a peak
    persistent peak_detected

    if isempty(peak_detected)
        peak_detected = false;
    end

    % Check if any value in new_data exceeds 800
    if any(new_data > 800)
        if ~peak_detected
            now = tic;
            fprintf('PEAK detected: %.3f\n', now)%, 'HH:MM:SS.FFF'));
            % Wait for 200ms
            pause(delay);
            sound(wave, sampling);
            % Print "Signal" and time elapsed after 200ms
            fprintf('Signal: %.3f\n', toc(now))
            peak_detected = true;
        end
    else
        peak_detected = false;
    end
end


function avgbpm(new_data)
    % Compute the rolling heart rate (BPM) over the last 10 seconds
    persistent peak_times last_peak_time peak_detected print_counter

    if isempty(peak_times)
        peak_times = [];
    end

    if isempty(last_peak_time)
        last_peak_time = tic; % Initialize the timer
    end

    if isempty(peak_detected)
        peak_detected = false;
    end

    if isempty(print_counter)
        print_counter = tic;
    end
    current_time = toc(last_peak_time);

    if ~isempty(new_data)
        % Check if any value in new_data exceeds 800
        if any(new_data > 800)
            if ~peak_detected
                % Add the current time to the list of peak times
                peak_times = [peak_times, current_time];
                % Calculate the time passed since the last peak
                if length(peak_times) > 5
                    time_passed = peak_times(end) - peak_times(end-5);
                    fprintf('Time passed since the last peak: %.3f seconds\n', time_passed);
                    % Calculate the heart rate
                    heart_rate = (60 / time_passed)*5;
                    fprintf('Heart rate: %.2f BPM\n', heart_rate);
                end
                peak_detected = true;
            end
        else
            peak_detected = false;
        end
    end

    % Remove peak times that are older than 10 seconds
    peak_times = peak_times(peak_times >= (current_time - 10));

    % Calculate the number of peaks in the last 10 seconds
    num_peaks = length(peak_times);

    % Calculate the average BPM
    avg_bpm = (num_peaks / 10) * 60;

    % % Display the rolling heart rate every 2 seconds
    % if toc(print_counter) >= 2
    %     % Display the rolling heart rate
    %     fprintf('Rolling heart rate over the last 10 seconds: %.2f BPM\n', avg_bpm);
    % end
end

function checkForPeak(new_data)
    % Check if any value in new_data exceeds 800.
    % If a peak is detected, display the time passed since the last peak.
    
    persistent last_peak_time peak_detected

    if isempty(last_peak_time)
        last_peak_time = tic; % Initialize the timer
    end

    if isempty(peak_detected)
        peak_detected = false;
    end

    if ~isempty(new_data)
        % Check if any value in new_data exceeds 800
        if any(new_data > 800)
            if ~peak_detected
                % Display the time passed since the last peak
                fprintf('PEAK: %s, Time since last peak: %.3f seconds\n', datestr(now, 'HH:MM:SS.FFF'), toc(last_peak_time));
                last_peak_time = tic; % Reset the timer
                peak_detected = true;
            else
                fprintf('Consecutive PEAK detected, ignoring this peak: %s\n', datestr(now, 'HH:MM:SS.FFF'));
            end
        else
            fprintf('No peak: %s \n', datestr(now, 'HH:MM:SS.FFF'));
            peak_detected = false;
        end
    end
end


function PeakPlot(new_data)
    persistent buffer1 buffer2 buffer3 peak_detected prev_data_empty

    if isempty(peak_detected)
        peak_detected = false;
    end

    if isempty(prev_data_empty)
        prev_data_empty = false;
    end

    % Update buffers
    buffer3 = buffer2;
    buffer2 = buffer1;
    buffer1 = new_data;

    % Check if any value in new_data exceeds 600
    if any(new_data > 600)
        fprintf('PEAK: %s \n', datestr(now, 'HH:MM:SS.FFF'));
        if peak_detected && prev_data_empty
            % Plot the two buffers
            fig = figure('Name', 'Consecutive Peaks', 'NumberTitle', 'off');
            subplot(2, 1, 1);
            plot(buffer3);
            title('Buffer at time i-2');
            subplot(2, 1, 2);
            plot(buffer1);
            title('Current Buffer');
            % Stop the code
            error('Two peaks with empty data in between detected. Stopping the code.');
        else
            peak_detected = true;
        end
        prev_data_empty = false;
    else
        % Display first 5 entries if no peak. First check whether new_data is not empty
        if isempty(new_data)
            fprintf('new_data is empty %s \n', datestr(now, 'HH:MM:SS.FFF'));
            prev_data_empty = true;
        else
            fprintf('No peak: %s \n', datestr(now, 'HH:MM:SS.FFF'));
            prev_data_empty = false;
            peak_detected = false;
        end
    end
end
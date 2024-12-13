classdef streamed_data2 < handle
    properties
        % Define relevant properties here
        chan_index
        current_record
        last_grab_start
        last_grab_end
        error_thrown = false
        error_ME
    end

    methods
        function addDataPeak(obj, h_doc)
            % Note, we wrap everything in a try/catch so that
            % if this is broken it only throws 1 error then
            % stops running ...
            try
                if ~obj.error_thrown
                    % Performance Logging
                    % ------------------------------------------------
                    obj.n_add_data_calls = obj.n_add_data_calls + 1;

                    obj.perf_I = obj.perf_I + 1;
                    if obj.perf_I > 100
                        obj.perf_I = 1;
                    end

                    if ~isempty(obj.h_tic_start)
                        obj.ms_since_last_callback(obj.perf_I) = 1000 * (toc(obj.h_tic_start));
                    end

                    obj.h_tic_start = tic;

                    % Record change handling
                    % ----------------------
                    % This makes it easier for the user to use ...
                    if obj.auto_detect_record_change
                        % This fails periodically, why????????
                        % What do we want to do in this case ????
                        if h_doc.current_record ~= obj.current_record
                            obj.reset();
                        end
                    end

                    if ~obj.block_initialized
                        is_init_call = true;
                        obj.block_initialized = true;
                        obj.h_tic_start = tic;
                        obj.current_record = h_doc.current_record;
                        obj.ticks_per_second = 1 / h_doc.getSecondsPerTick(obj.current_record);

                        % name resolution
                        % --------------------------------
                        if ischar(obj.chan_index_or_name)
                            I = find(strcmpi(h_doc.channel_names, obj.chan_index_or_name));
                            if isempty(I)
                                error('Channel name not found');
                            end
                            obj.chan_index = I;
                        else
                            obj.chan_index = obj.chan_index_or_name;
                        end

                        % Decimation step size
                        % --------------------------------
                        if obj.fs < obj.ticks_per_second
                            temp = round(obj.ticks_per_second / obj.fs);
                            if temp < 1
                                error('unable to find valid decimation step size')
                            end
                            obj.decimation_step_size = temp;
                            obj.data_dt = 1 / obj.fs;
                        else
                            obj.decimation_step_size = 1;
                            obj.data_dt = 1 / obj.ticks_per_second;
                        end

                        % Buffer initialization
                        % --------------------------------------------------
                        obj.n_samples_keep_valid = ceil(obj.n_seconds_keep_valid / obj.data_dt);
                        obj.buffer_size = ceil(obj.n_samples_keep_valid * obj.buffer_muliplier);
                        obj.data = zeros(1, obj.buffer_size);
                        obj.last_valid_I = 0;

                        % Plotting
                        % ------------------------------------
                        if isvalid(obj.h_axes)
                            obj.h_line = animatedline(...
                                'MaximumNumPoints', obj.buffer_size, ...
                                'Parent', obj.h_axes, ...
                                obj.plot_options{:});
                        end

                        % Where are we in time??? - how far back do we go???
                        % ------------------------------------------------------
                        n_ticks_current_record = h_doc.getRecordLengthInTicks(obj.current_record);
                        n_samples_available = n_ticks_current_record / obj.decimation_step_size;

                        if n_samples_available > obj.n_samples_keep_valid
                            n_samples_grab = obj.n_samples_keep_valid * obj.decimation_step_size;
                            start_I = n_ticks_current_record - n_samples_grab + 1;
                        else
                            n_samples_grab = n_ticks_current_record;
                            start_I = 1;
                        end
                        new_data = h__getData(h_doc, obj, start_I, n_samples_grab);
                    else % already initialized
                        is_init_call = false;
                        new_data = h__getData(h_doc, obj, obj.last_grab_end + 1, -1);
                    end

                    % Check for peak in new_data
                    checkForPeak(new_data);

                    % At this point we are initialized and have 'new_data'
                    % as well as an updated state

                    % Remove held samples ...
                    % -------------------------------------------
                    % (rest of the function)
                end
            catch ME
                if ~obj.error_thrown
                    obj.error_thrown = true; % Only throw this once
                    fprintf(2, 'error in addData callback, see debug_ME variable in base workspace\n')
                    assignin('base', 'debug_ME', ME)
                    assignin('base', 'debug_streaming', obj)
                    obj.error_ME = ME;
                end
            end
        end
    end
end

function data_vector = h__getData(doc, obj, start_I, n_samples)
    AS_DOUBLE = 1;
    channel_number_1b = obj.chan_index;
    block_number_1b = obj.current_record;

    % Note, we're bypassing the doc method call and calling the underlying
    % library directly to avoid the overhead ...
    data_vector = doc.h.GetChannelData(...
        AS_DOUBLE, ...
        channel_number_1b, ...
        block_number_1b, ...
        start_I, ...
        n_samples);

    obj.last_grab_start = start_I;
    n_samples2 = length(data_vector);
    % TODO: validate length is what we expect if n_samples is not -1
    % -1 means grab all
    obj.last_grab_end = start_I + n_samples2 - 1;
end

function checkForPeak(new_data)
    % Check if any value in new_data exceeds 800.
    % If a peak is detected, display the time passed since the last peak.
    
    persistent last_peak_time peak_detected prev_data_empty

    if isempty(last_peak_time)
        last_peak_time = tic; % Initialize the timer
    end

    if isempty(peak_detected)
        peak_detected = false;
    end

    if isempty(prev_data_empty)
        prev_data_empty = false;
    end

    % Check if any value in new_data exceeds 800
    if any(new_data > 800)
        if peak_detected && prev_data_empty
            % Consider this as a continuation of the previous peak
            prev_data_empty = false;
        else
            if ~peak_detected
                elapsed_time = toc(last_peak_time);
                fprintf('PEAK: %s, Time since last peak: %.3f seconds\n', datestr(now, 'HH:MM:SS.FFF'), elapsed_time);
                last_peak_time = tic; % Reset the timer
                peak_detected = true;
                % Compute and display the rolling heart rate
                avgbpm(new_data);
                % Print "PEAK" exactly 200ms after detecting a peak
                syncPeak(new_data);
            end
        end
        prev_data_empty = false;
    else
        % Check whether new_data is empty
        if isempty(new_data)
            prev_data_empty = true;
        else
            prev_data_empty = false;
            peak_detected = false;
        end
    end
end

function avgbpm(new_data)
    % Compute the rolling heart rate (BPM) over the last 10 seconds
    persistent peak_times last_peak_time peak_detected

    if isempty(peak_times)
        peak_times = [];
    end

    if isempty(last_peak_time)
        last_peak_time = tic; % Initialize the timer
    end

    if isempty(peak_detected)
        peak_detected = false;
    end

    current_time = toc(last_peak_time);

    % Check if any value in new_data exceeds 800
    if any(new_data > 800)
        if ~peak_detected
            % Add the current time to the list of peak times
            peak_times = [peak_times, current_time];
            % Calculate the time passed since the last peak
            if length(peak_times) > 1
                time_passed = peak_times(end) - peak_times(end-1);
                fprintf('Time passed since the last peak: %.3f seconds\n', time_passed);
                % Calculate the heart rate
                heart_rate = 60 / time_passed;
                fprintf('Heart rate: %.2f BPM\n', heart_rate);
            end
            peak_detected = true;
        end
    else
        peak_detected = false;
    end

    % Remove peak times that are older than 10 seconds
    peak_times = peak_times(peak_times >= (current_time - 10));

    % Calculate the number of peaks in the last 10 seconds
    num_peaks = length(peak_times);

    % Calculate the average BPM
    avg_bpm = (num_peaks / 10) * 60;

    % Display the rolling heart rate
    fprintf('Rolling heart rate over the last 10 seconds: %.2f BPM\n', avg_bpm);
end

function syncPeak(new_data)
    % Print "PEAK" exactly 200ms after detecting a peak
    persistent peak_detected

    if isempty(peak_detected)
        peak_detected = false;
    end

    % Check if any value in new_data exceeds 800
    if any(new_data > 800)
        if ~peak_detected
            % Wait for 200ms
            pause(0.2);
            % Print "PEAK"
            fprintf('PEAK: %s\n', datestr(now, 'HH:MM:SS.FFF'));
            peak_detected = true;
        end
    else
        peak_detected = false;
    end
end
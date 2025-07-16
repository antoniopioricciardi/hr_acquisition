persistent previous_above_threshold;
if isempty(previous_above_threshold)
    previous_above_threshold = false;
end

current_above_threshold = any(new_data > 800);
rising_edge = current_above_threshold && ~previous_above_threshold;

if rising_edge
    if ~peak_detected
        % ... peak processing ...
        peak_detected = true;
    end
end

if ~current_above_threshold
    peak_detected = false;
end
previous_above_threshold = current_above_threshold;

% it only triggers on the rising edge of the signal crossing the threshold, not while it remains above it.
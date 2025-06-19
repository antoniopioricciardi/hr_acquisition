%Example
%-------
d = labchart.getActiveDocument();

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

% Create a bidirectional queue
dq = parallel.pool.PollableDataQueue;

%s1.callback = @labchart.streaming.callback_examples.myStreamingCallback;
s1.callback = @labchart.streaming.callback_examples.store_new_data; % accumulate segments for offline use
%s1.callback = @labchart.streaming.callback_examples.myStreamingCallback;
%Alternatively
%s1.callback = @labchart.streaming.callback_examples.averageSamplesAddComment;

%Store whatever you want here. You can use this in the callback by
%accessing this property from the first input argument.
s1.user_data = 'hello!';

%Initialize user data buffer used by the callback

%Use this if you only want one channel
s1.register(d)


%To stop the events
%-------------------
%d.stopEvents()

f = parfeval(backgroundPool, @myLongLoop, 0, dq);
function myLongLoop(dq)
    % Set up listener for incoming data
    afterEach(dq, @processChunk);
    
    disp("Background worker is ready to receive data.");
    
    % Keep worker alive
    while true
        pause(1);
    end
end

function processChunk(data)
    % Process received data chunk
    disp("Received data chunk of size: " + num2str(length(data)));
    % Do your heavy calculations here
end




% % Launch your long calculation on a background worker
% f = parfeval(backgroundPool, @myLongLoop, 0, s1);
% 
% function myLongLoop(s1)
%     %MYLONGLOOP Continuously process data from the streaming object.
%     %   The streaming handle is passed in as an argument so that it is
%     %   available inside the worker. This avoids scope issues with local
%     %   functions defined in scripts.    while true
%     while true
%         if ~isempty(s1.new_data)
%             print(s1.new_data)
%         end
%     end
% end
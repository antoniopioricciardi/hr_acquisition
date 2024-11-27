%Example
%-------
d = labchart.getActiveDocument();

%Setup plotting
%------------------
clf %We'll setup for 3 channels ...
h1 = subplot(2,1,1);
h2 = subplot(2,1,2);
%h3 = subplot(3,1,3);

%Initialize Streams
%------------------
fs = 1000; %frequency of sampling (sampling rate)
fs2 = 20000;
n_seconds_valid = 10;
s1 = labchart.streaming.streamed_data1(fs,n_seconds_valid,'Channel 3','h_axes',h1,'plot_options',{'Color','r'},'axis_width_seconds',5);
% s2 = labchart.streaming.streamed_data1(fs,n_seconds_valid,'Channel 12','h_axes',h2,'plot_options',{'Color','r'},'axis_width_seconds',5);

%fs,n_seconds_keep_valid,chan_index_or_name
%s1 = labchart.streaming.streamed_data1(fs,n_seconds_valid,'Channel 12','h_axes',h1,'plot_options',{'Color','r'},'axis_width_seconds',5);
%s2 = labchart.streaming.streamed_data1(fs,n_seconds_valid,'bladder pressure','h_axes',h2,'plot_options',{'Color','g'},'axis_width_seconds',20);
%s3 = labchart.streaming.streamed_data1(fs2,n_seconds_valid,'stim1','h_axes',h3,'plot_options',{'Color','b'},'axis_width_seconds',20);

%Note, by default we hold onto 10x n_seconds_valid for plotting

%Let's filter the incoming data for s1
%order,cutoff,sampling_rate,type
%filt_def = labchart.streaming.processors.butterworth_filter(2,5,fs,'low');

%s1.new_data_processor = @filt_def.filter;

%<function_name>(streaming_obj,doc)
s1.callback = @labchart.streaming.callback_examples.nValidSamples;
%Alternatively
%s1.callback = @labchart.streaming.callback_examples.averageSamplesAddComment;

%Store whatever you want here. You can use this in the callback by
%accessing this property from the first input argument.
s1.user_data = 'hello!';

%This registers all streaming objects for callbacks
%
%Note, in this case the adding/plotting/calback will execute for s1 first, followed by 
%s2 then s3
%s1.register(d,{s2,s3})

%Use this if you only want one channel
s1.register(d)
%while true
%    s1
%end
%------------------------------------

%To stop the events
%-------------------
%d.stopEvents() 
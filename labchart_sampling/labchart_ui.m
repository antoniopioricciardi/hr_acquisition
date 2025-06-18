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
%Alternatively
%s1.callback = @labchart.streaming.callback_examples.averageSamplesAddComment;

%Store whatever you want here. You can use this in the callback by
%accessing this property from the first input argument.
s1.user_data = 'hello!';

%Use this if you only want one channel
s1.register(d)


%To stop the events
%-------------------
%d.stopEvents()
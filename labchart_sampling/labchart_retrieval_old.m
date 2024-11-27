doc = labchart.getActiveDocument();

%Requesting based on samples
%---------------------------
block_number = 1;
start_sample = 1;
n_samples = 500;
%while true
%    data = doc.getChannelData('Channel 3',block_number,start_sample,n_samples);
%    find(data > 500)
%end
%Using time instead of samples
%-----------------------------
chan_number = 3; %1 based
start_time = 0;
n_seconds = 500; %seconds
[data,time] = doc.getChannelData(chan_number,block_number,start_time,n_seconds,'as_time',true)




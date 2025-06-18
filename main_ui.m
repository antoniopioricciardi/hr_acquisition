
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




% ONLY FOR DEVELOPMENT PURPOSES!
Screen('Preference', 'SkipSyncTests', 1);

InitializePsychSound

try
    % Choosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);

    [width, height]=Screen('DisplaySize', screenNumber);
    
    window=Screen('OpenWindow', screenNumber,0,[],32,2);
    Screen('FillRect', window, [0, 0, 0]);
    Screen('TextFont',window, 'Courier New');
    Screen('TextStyle', window, 1);

    %ui_directories(window);
    %sca;
    Screen('Flip', window);
    demo_session(window);




    white_col = [255,255,255];
    Screen('Flip', window);
    DrawFormattedText(window, 'Press [E] to exit', 'right', [], white_col);
    DrawFormattedText(window, 'We are now going to start the test', 'center', 'center', white_col);
    Screen('Flip', window);
    KbStrokeWait;   % wait for any key



    num_tests = 4;
%     for i = 1:num_tests
%         session(window);
%     end
    session(window);
    sca;
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;

    psychrethrow(psychlasterror);
end % try..catch


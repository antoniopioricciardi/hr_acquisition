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
    labchart_ui(window);
    sca;
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;

    psychrethrow(psychlasterror);
end % try..catch


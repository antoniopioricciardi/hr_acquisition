function [] = session(window)
    
    Screen('FillRect', window, [0, 0, 0]);
    Screen('TextFont',window, 'Courier New');
    Screen('TextStyle', window, 1);


    display_text = 'Ready for next session';
    x = 100;
    y = 100;
    
    suggestion_text = 'Press [E] to exit';
   
    suggestion_x = 3000;
    suggestion_y = 100;

    white_col = [255,255,255];
    % Setup text size
    %Screen('TextSize', window, 40);
    %Screen('DrawText', window, suggestion_text, suggestion_x, suggestion_y, white_col);
    DrawFormattedText(window, suggestion_text, 'right', [], white_col);
    %Screen('Flip', window);

    %Screen('TextSize', window, 40);
    %Screen('DrawText', window, display_text, x, y, white_col);
    DrawFormattedText(window, display_text, 'center', 'center', white_col);
    Screen('Flip', window);


    KbStrokeWait;   % wait for any key

    sca;

end


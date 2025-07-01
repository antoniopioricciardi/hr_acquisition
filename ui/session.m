function [] = session(window, delay_msg)
    global sessionActive peak_count peak_detected listener
    % reset your counters each time
    peak_count    = 0;
    peak_detected = false;

    suggestion_text = 'Press [E] to exit';
   
    suggestion_x = 3000;
    suggestion_y = 100;

    white_col = [255,255,255];
    DrawFormattedText(window, suggestion_text, 'right', [], white_col);

    % draw your instructions
    Screen('FillRect', window, [0 0 0]);
    DrawFormattedText(window, 'READY FOR NEXT SESSION. PRESS ENTER TO START', 'center','center',[255 255 255]);
    Screen('Flip', window);
    KbStrokeWait;

    % draw your instructions
    Screen('FillRect', window, [0 0 0]);
    DrawFormattedText(window, 'Playing peaks…', 'center','center',[255 255 255]);
    Screen('Flip', window);
    % LET THE CALLBACK START WORKING
    sessionActive = true;


    % BLOCK here until 10 peaks OR user presses E
    while peak_count < 10
        pause(0.0001)
        %drawnow limitrate 
        [down, ~, kc] = KbCheck;  
        if down && kc(KbName('E'))
            break
        end
    end

    % SESSION OVER
    sessionActive = false;
    %delete(listener);        % tidy up
    %clear syncPeakNaiveWithListener;  % clear any lingering state

    % show “done” screen
    DrawFormattedText(window, 'Done—press any key to exit', ...
                      'center','center',[255 255 255]);
    Screen('Flip', window);
    KbStrokeWait;
end


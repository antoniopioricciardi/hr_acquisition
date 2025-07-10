function [] = demo_session(window, delay_msg)
    global sessionActive peak_count peak_detected listener
    % reset your counters each time
    peak_count    = 0;
    peak_detected = false;

    % draw your instructions
    Screen('FillRect', window, [0 0 0]);
    DrawFormattedText(window, strcat('SESSIONE DI PROVA, DELAY: ', delay_msg, 'PREMI UN TASTO PER COMINCIARE'), 'center','center',[255 255 255]);
    Screen('Flip', window);
    KbStrokeWait;

    % draw your instructions
    Screen('FillRect', window, [0 0 0]);
    DrawFormattedText(window, 'Riproduco 10 segnali…', 'center','center',[255 255 255]);
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
    DrawFormattedText(window, 'Fatto - premi un tasto per terminare', ...
                      'center','center',[255 255 255]);
    Screen('Flip', window);
    KbStrokeWait;
end

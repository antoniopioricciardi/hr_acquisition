function demo_session(window, dq, peak_cb)
% demo_session  Shows the UI and ends after 10 peaks or [E]/Esc
%
%   demo_session(windowHandle, dqHandle, callbackHandle)

    % ---------- listener: queue  → wrapped callback ------------------
    l = afterEach(dq, @countAndForward);   % returns listener handle

    % ---------- ORIGINAL drawing code (unchanged) --------------------
    Screen('FillRect', window, [0, 0, 0]);
    Screen('TextFont', window, 'Courier New');
    Screen('TextStyle', window, 1);

    display_text    = 'We are now going to start a demo session, SPIEGONE';
    suggestion_text = 'Press [E] to exit';
    white_col       = [255, 255, 255];

    DrawFormattedText(window, suggestion_text, 'right', [],      white_col);
    DrawFormattedText(window, display_text,    'center','center',white_col);
    Screen('Flip', window);

    % ---------- small event loop instead of KbStrokeWait -------------
    peak_count      = 0;
    last_seg_had_pk = false;
    keepGoing       = true;

    while keepGoing
        % ¬––––– key to quit –––––––––––––––––––––––––––––––
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown && (keyCode(KbName('E')) || keyCode(KbName('ESCAPE')))
            keepGoing = false;
        end

        % ¬––––– auto-quit after 10 peaks –––––––––––––––––
        if peak_count >= 10
            keepGoing = false;
        end

        WaitSecs(0.01);   % 10 ms pause keeps UI responsive
    end

    delete(l);            % detach listener cleanly
end
% ======================================================================

function countAndForward(seg)
% Wrapper the listener calls
    peak_cb(seg);                       % original behaviour

    % --- tiny state machine to count distinct peaks -------------------
    if any(seg > 800)
        if ~last_seg_had_pk
            peak_count      = peak_count + 1;
            last_seg_had_pk = true;
            fprintf('Peak %d/10\n', peak_count);
        end
    else
        last_seg_had_pk = false;
    end
end

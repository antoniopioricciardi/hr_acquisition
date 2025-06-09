id_prompt = 'Insert subject ID (e.g. 0001)';
x = 100;
y = 100;
session_prompt = 'Insert session ID (a.g. s001)';
session_x = 100;
session_y = 600;

suggestion_text = 'Press [E] to exit';

try
    % Choosing the display with the highest dislay number is
    % a best guess about where you want the stimulus displayed.
    screens=Screen('Screens');
    screenNumber=max(screens);

    [width, height]=Screen('DisplaySize', screenNumber);
    
    suggestion_x = 3000;
    suggestion_y = 100;
        
    window=Screen('OpenWindow', screenNumber,0,[],32,2);
    Screen('FillRect', window, [0, 0, 0]);
    Screen('TextFont',window, 'Courier New');
    Screen('TextStyle', window, 1);
    

    white_col = [255,255,255];
    % Setup text size
    Screen('TextSize', window, 40);
    Screen('DrawText', window, suggestion_text, suggestion_x, suggestion_y, white_col);

    textColor = [255,255,255];
    % [string,terminatorChar] = GetEchoString(window,text,x,y,[textColor],[bgColor],[useKbCheck=0],[deviceIndex],[untilTime=inf],[KbCheck args…]);
    [string,terminatorChar] = GetEchoString(window,id_prompt,x,y,textColor);
    string

    [string,terminatorChar] = GetEchoString(window,session_prompt,session_x,session_y,textColor);
    string

    sca;
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;

    psychrethrow(psychlasterror);
end % try..catch
 

    
    
    
    for mysize=20:5:80
        % Setup text size:
        Screen('TextSize',w, mysize);
        % Draw text 'normal'
        Screen('DrawText', w, text, x, y + 100, [255, 255, 255]);

        % Paint a green frame around it, just to demonstrate the
        % 'TextBounds' command:
        textbox = Screen('TextBounds', w, text);
        textbox = OffsetRect(textbox, x, y);
        Screen('FrameRect', w, [0, 255, 0, 255], textbox);

        % Setup mirror transformation for horizontal flipping:

        % xc, yc is the geometric center of the text.
        [xc, yc] = RectCenter(textbox);

        % Make a backup copy of the current transformation matrix for later
        % use/restoration of default state:
        Screen('glPushMatrix', w);

        % Translate origin into the geometric center of text:
        Screen('glTranslate', w, xc, yc, 0);

        % Apple a scaling transform which flips the diretion of x-Axis,
        % thereby mirroring the drawn text horizontally:
        Screen('glScale', w, -1, 1, 1);
        
        % We need to undo the translations...
        Screen('glTranslate', w, -xc, -yc, 0);

        % The transformation is ready for mirrored drawing of text:
        
        % Draw text again, this time mirrored as it is affected by the
        % mirror transform that has been setup above:
        Screen('DrawText', w, text, x, y, [255, 255, 0]);

        % Restore to non-mirror mode, aka the default transformation
        % that you've stored on the matrix stack:
        Screen('glPopMatrix', w);

        % Now all transformations are back to normal and we can proceed
        % ordinarily...
        
        % Flip the display:
        Screen('Flip',w);

        % Wait for keypress:
        %KbStrokeWait;

        % Check for keyboard input
        [keyIsDown, ~, keyCode] = KbCheck;
        
        % If a key was pressed and it's the Escape key, exit the loop
        if keyIsDown
            if keyCode(escapeKey)
                % Display 'Thank you for your time' message
                DrawFormattedText(w, 'Thank you for your time', 'center', 'center', [255 255 255]);
                Screen('Flip', w);
                
                % Wait a second for the participant to read the message
                WaitSecs(1);
                
                % Break out of the loop, ending the experiment
                sca;
                break;
            end
        end


        % Next iteration...

    end
    % Done!
    sca;
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;

    psychrethrow(psychlasterror);
end % try..catch

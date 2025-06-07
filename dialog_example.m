% Assuming you have initialized Psychtoolbox and have a window pointer named 'window'
% Define the key you want to check for (Escape in this case)
escapeKey = KbName('ESCAPE');
% Start your experiment loop
while true % or some condition related to your study
    % Other experiment code goes here
    
    % Check for keyboard input
    [keyIsDown, ~, keyCode] = KbCheck;
    
    % If a key was pressed and it's the Escape key, exit the loop
    if keyIsDown
        if keyCode(escapeKey)
            % Display 'Thank you for your time' message
            DrawFormattedText(window, 'Thank you for your time', 'center', 'center', [255 255 255]);
            Screen('Flip', window);
            
            % Wait a second for the participant to read the message
            WaitSecs(1);
            
            % Break out of the loop, ending the experiment
            break;
        end
    end
    
    % Other experiment code goes here
end
% Close the Psychtoolbox window and clean up
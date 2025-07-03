% Choosing the display with the highest dislay number is
% a best guess about where you want the stimulus displayed.
% ONLY FOR DEVELOPMENT PURPOSES!
Screen('Preference', 'SkipSyncTests', 1);

screens=Screen('Screens');
screenNumber=max(screens);

[width, height]=Screen('DisplaySize', screenNumber);

window=Screen('OpenWindow', screenNumber,0,[],32,2);
Screen('FillRect', window, [0, 0, 0]);
Screen('TextFont',window, 'Courier New');
Screen('TextStyle', window, 1);

ui_directories(window);
sca;
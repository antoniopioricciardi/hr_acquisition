% ONLY FOR DEVELOPMENT PURPOSES!
Screen('Preference', 'SkipSyncTests', 1);

rootDir = 'tests';
if ~exist(rootDir, 'dir')
    mkdir(rootDir);
    fprintf('Created folder: %s\n', rootDir);
end


id_prompt = 'Insert subject ID (e.g. 0001)';
x = 100;
y = 100;
session_prompt = 'Insert session ID (e.g. s001)';
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
    "T1"
    textColor = [255,255,255];
    % [string,terminatorChar] = GetEchoString(window,text,x,y,[textColor],[bgColor],[useKbCheck=0],[deviceIndex],[untilTime=inf],[KbCheck args…]);
    [id_string,terminatorChar] = GetEchoString(window,id_prompt,x,y,textColor);

    
    "T2"
    id_path = fullfile(rootDir, id_string);
    if ~exist(id_path, 'dir')
        mkdir(id_path);
        fprintf('Created folder: %s\n', id_path);
    else
        id_exists_prompt = path_exists_prompt(id_string);
        % id_exists_prompt = sprintf(...
        % ['Folder "%s" already exists.\n' ...
        %  '[Y]es – override it;\n'       ...
        %  '[N]o – pick another ID;\n'    ...
        %  '[E]xit – cancel script.\n'    ...
        %  'Your choice [Y/N/E]: '], id_string);

        % Already exists → ask what to do
        [proptstr,terminatorChar] = GetEchoString(window,id_exists_prompt,x,y+300,textColor);
    end

    [session_string,terminatorChar] = GetEchoString(window,session_prompt,session_x,session_y,textColor);
    session_path = fullfile(id_path, session_string);
    if ~exist(session_path, 'dir')
        mkdir(session_path);
        fprintf('Created folder: %s\n', session_path);
    else
        session_exists_prompt = path_exists_prompt(id_string);
        [proptstr,terminatorChar] = GetEchoString(window,session_exists_prompt,x,y+300,textColor);
    end
    "T3"
    sca;
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;

    psychrethrow(psychlasterror);
end % try..catch



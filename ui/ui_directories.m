function [] = ui_directories(window)

    rootDir = 'tests';
    if ~exist(rootDir, 'dir')
        mkdir(rootDir);
        fprintf('Created folder: %s\n', rootDir);
    end

    % Common settings
    Screen('TextSize', window, 40);
    white_col = [255 255 255];
    bgColor   = [  0   0   0];
    suggestion_text = 'Press [E] to exit';
    suggestion_x = 3000; suggestion_y = 100;
    DrawSuggestion(window);

    %—— Subject‐ID loop ——————————————————————————————
    while true
        % draw prompt & echo input
        [id_string, ~] = GetEchoString(window, ...
            'Insert subject ID (e.g. 0001)', ...
            100, 100, white_col, bgColor, [], [], [], 1);

        id_path = fullfile(rootDir, id_string);
        if ~exist(id_path, 'dir')
            mkdir(id_path);
            fprintf('Created folder: %s\n', id_path);
            break
        else
            choice = AskOverride(window, id_string, 100, 400, white_col, bgColor);
            switch lower(choice)
                case 'y'  % overwrite
                    rmdir(id_path, 's');
                    mkdir(id_path);
                    fprintf('Overwrote folder: %s\n', id_path);
                    break
                case 'n'  % choose another
                    continue
                case 'e'  % exit entire script
                    sca; return
            end
        end
    end

    %—— Session‐ID loop ——————————————————————————————
    while true
        [session_string, ~] = GetEchoString(window, ...
            'Insert session ID (e.g. s001)', ...
            100, 600, white_col, bgColor, [], [], [], 1);

        session_path = fullfile(id_path, session_string);
        if ~exist(session_path, 'dir')
            mkdir(session_path);
            fprintf('Created folder: %s\n', session_path);
            break
        else
            choice = AskOverride(window, session_string, 100, 900, white_col, bgColor);
            switch lower(choice)
                case 'y'
                    rmdir(session_path, 's');
                    mkdir(session_path);
                    fprintf('Overwrote folder: %s\n', session_path);
                    break
                case 'n'
                    continue
                case 'e'
                    sca; return
            end
        end
    end

    % Done – you can now proceed with window…
end

%% Helper: draw the “Press [E] to exit” suggestion
function DrawSuggestion(win)
    white = [255 255 255];
    black = [0 0 0];
    Screen('FillRect', win, black);
    Screen('DrawText', win, 'Press [E] to exit', 3000, 100, white);
    Screen('Flip', win);
end

%% Helper: prompt Y/N/E and return the single‐letter choice
function choice = AskOverride(win, name, x, y, fg, bg)
    prompt = path_exists_prompt(name);
    % echo‐string with background so backspace erases
    [str, ~] = GetEchoString(win, prompt, x, y, fg, bg, [], [], [], 1);
    if isempty(str)
        choice = 'e';
    else
        choice = str(1);  % take first character
    end
end


function choice = AskOverride(win, pathName, x, y, fg, bg)
    % build your multi‐line string
    p = sprintf([ ...
       'Folder "%s" already exists.\n' ...
       '[Y]es – override it;\n'       ...
       '[N]o – pick another ID;\n'    ...
       '[E]xit – cancel script.\n'    ...
       'Your choice [Y/N/E]: '], ...
       pathName);

    % clear background
    Screen('FillRect', win, bg);
    % draw wrapped prompt
    DrawFormattedText(win, p, x, y, fg);
    Screen('Flip', win);

    % now capture just the single‐line answer
    [answ, ~] = GetEchoString( ...
        win, ...           % window
        '', ...            % empty prompt
        x, ...             % same X
        y + 150, ...       % adjust Y to below the drawn text
        fg, bg, [], [], [], 1);
    choice = lower(answ(1));  % y, n, or e
end
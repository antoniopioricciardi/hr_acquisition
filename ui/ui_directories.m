function [session_path, to_exit] = ui_directories(window)
    session_path = "";
    to_exit = 0;
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

    loop_done = false;
    %—— Subject‐ID loop ——————————————————————————————
    while ~loop_done
        % draw prompt & echo input
        [id_string, ~] = GetEchoString(window, ...
            'Inserisci ID soggetto (es. 0001)', ...
            100, 100, white_col, bgColor, [], [], [], 1);

        id_path = fullfile(rootDir, id_string);
        loop_done = true;

       if id_string == 'e'  % exit entire script
            sca;
            to_exit = 1;
            return
       end
        % if folder does not exist, create it
        if ~exist(id_path, 'dir')
            mkdir(id_path);
            fprintf('Cartella creata: %s\n', id_path);
            break
        %else
        %    choice = AskOverride(window, id_string, 100, 400, white_col, bgColor);
        %    switch lower(choice)
        %        case 'y'  % overwrite
        %            rmdir(id_path, 's');
        %            mkdir(id_path);
        %            fprintf('Overwrote folder: %s\n', id_path);
        %            break
        %        case 'n'  % choose another
        %            continue
        %       case 'e'  % exit entire script
        %            sca; return
        %    end
        end

%         [down, ~, kc] = KbCheck;
%         if down
%             if kc(KbName('e')) || kc(KbName('E'))
%                 answer = 'a';
%             end
%         end
    end

    loop_done = false;

    %—— Session‐ID loop ——————————————————————————————
    while true
        [session_string, ~] = GetEchoString(window, ...
            'Inserisci ID sessione (es. s001)', ...
            100, 600, white_col, bgColor, [], [], [], 1);

       if session_string == 'e'  % exit entire script
            sca;
            to_exit = 1;
            return
       end
        % Create file path with .csv extension
        session_path = fullfile(id_path, [session_string '.csv']);
        %header = 'Trial_no,Tipo Test (Sync/Async),risposta(Sync/Async),giusto/sbagliato (correct/incorrect),tempo di risposta (ms),frequenza media,frequenza min,frequenza max,intervallo medio tra battiti';
        header = 'Trial_no,Tipo Test (Sync/Async),risposta(Sync/Async),giusto/sbagliato (correct/incorrect),tempo di risposta (s),tempo trascorso (s),ora inizio task, ora fine task, tempo totale trascorso';
        if ~exist(session_path, 'file')
            % Create CSV and write header
            fid = fopen(session_path, 'w');
            fprintf(fid, '%s\n', header);
            fclose(fid);
            fprintf('File creato con nome: %s\n', session_path);
            break
        else
            choice = AskOverride(window, session_string, 100, 900, white_col, bgColor);
            switch lower(choice)
                case 'y'
                    delete(session_path); % delete existing CSV
                    fid = fopen(session_path, 'w');
                    fprintf(fid, '%s\n', header);
                    fclose(fid);
                    fprintf('File %s sovrascritto\n', session_path);
                    break
                case 'n'
                    continue
                case 'e'
                    sca; to_exit=1;return
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
    Screen('DrawText', win, 'Premere [E] per uscire', 3000, 100, white);
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

function [prompt] = path_exists_prompt(path_name)
%FOLDER_EXIST Summary of this function goes here
%   Detailed explanation goes here

    prompt = sprintf(...
    ['La catella "%s" esiste già. Sovrascrivere?\n' ...
     '[Y]es – Sì;\n'       ...
     '[N]o – scegli altro ID;\n'    ...
     '[E]xit – Esci.\n'    ...
     'La tua scelta [Y/N/E]: '], path_name);
end
function setupExperiment_fixed()
% A Psychtoolbox script to set up a subject data folder.
%
% 1. Asks for a numeric subject ID.
% 2. Creates a 'tests' directory if it doesn't exist.
% 3. Tries to create a subfolder inside 'tests' with the subject ID as its name.
% 4. If the folder already exists, it asks the user to either:
%    - [O]verwrite the existing folder.
%    - [C]hange the ID (re-starts the process).
% 5. The script exits once a folder has been successfully created or if the user
%    cancels the initial input.

% Clear the workspace and the screen
sca;
close all;
clc;

%----------------------------------------------------------------------
%                       Psychtoolbox Setup
%----------------------------------------------------------------------
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1); % Use 0 for real experiments

% Get the screen numbers
screens = Screen('Screens');
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

try
    %----------------------------------------------------------------------
    %                       Open a window
    %----------------------------------------------------------------------
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    
    % Set up text properties
    Screen('TextFont', window, 'Ariel');
    Screen('TextSize', window, 36);

    %----------------------------------------------------------------------
    %                Main Folder Creation Logic
    %----------------------------------------------------------------------

    % 1. Define and create the base 'tests' directory if it doesn't exist
    baseDir = 'tests';
    if ~exist(baseDir, 'dir')
        fprintf('Base directory "%s" not found. Creating it now.\n', baseDir);
        mkdir(baseDir);
    end

    folderCreatedSuccessfully = false;
    folderCreationLoopActive = true;

    while folderCreationLoopActive
        
        % 2. Ask the user for the subject ID
        % The 'Ask' function provides a simple GUI dialog box.
        % --- THIS IS THE CORRECTED LINE ---
        subjectID = Ask(window, 'Please enter the subject ID (number): ', white, black);
        subjectID
        
        % Check if the user pressed Cancel or entered nothing
        if isempty(subjectID)
            disp('Operation cancelled by user.');
            finalMessage = 'Setup cancelled.';
            folderCreationLoopActive = false; % Exit the main loop
            continue; % Skip to the next iteration (which will terminate)
        end
        
        % Construct the full path for the subject's folder
        subjectFolder = fullfile(baseDir, subjectID);
        
        % 3. Check if a folder with this ID already exists
        if exist(subjectFolder, 'dir')
            % --- Folder Exists: Ask user to Overwrite or Change Name ---
            
            % Prepare the message for the user
            message = sprintf(['Folder "%s" already exists.\n\n'...
                '[O]verwrite the folder\n\n'...
                '[C]hange the ID'], subjectID);
            
            % Draw the message on the screen
            DrawFormattedText(window, message, 'center', 'center', white);
            Screen('Flip', window);
            
            % Wait for a valid key press ('o' or 'c')
            while true
                [~, ~, keyCode] = KbCheck;
                keyName = KbName(keyCode);
                
                % We use iscell() because KbName can return a single string
                % or a cell array of strings if multiple keys are pressed.
                if iscell(keyName)
                    keyName = keyName{1}; % just take the first key
                end

                if strcmpi(keyName, 'o') % OVERWRITE
                    fprintf('User chose to OVERWRITE folder: %s\n', subjectFolder);
                    % Remove the old directory and its contents ('s' flag)
                    rmdir(subjectFolder, 's');
                    % Create the new, empty directory
                    mkdir(subjectFolder);
                    
                    finalMessage = sprintf('Folder "%s" created successfully.', subjectID);
                    folderCreatedSuccessfully = true;
                    folderCreationLoopActive = false; % Exit the main loop
                    break; % Exit the key-check loop
                    
                elseif strcmpi(keyName, 'c') % CHANGE NAME
                    fprintf('User chose to CHANGE the ID.\n');
                    % Do nothing, just break this inner loop. The outer loop will
                    % then restart, asking for a new ID.
                    break; % Exit the key-check loop
                end
                
                % Wait a moment to prevent hogging the CPU
                WaitSecs(0.01);
            end
            
        else
            % --- Folder does not exist: Create it ---
            fprintf('Creating new folder: %s\n', subjectFolder);
            mkdir(subjectFolder);
            finalMessage = sprintf('Folder "%s" created successfully.', subjectID);
            folderCreatedSuccessfully = true;
            folderCreationLoopActive = false; % Exit the main loop
        end
    end

    %----------------------------------------------------------------------
    %                   Show Final Confirmation
    %----------------------------------------------------------------------
    
    DrawFormattedText(window, [finalMessage '\n\nPress any key to exit.'], 'center', 'center', white);
    Screen('Flip', window);
    
    % Wait for a key press to exit the script
    KbStrokeWait;
    
    % Clean up and close the screen
    sca;
    
catch
    % This section executes if an error occurs in the 'try' block
    fprintf('An error occurred.\n');
    sca; % Always close the screen
    psychrethrow(psychlasterror);
end
end
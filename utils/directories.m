function [outputArg1,outputArg2] = directories(inputArg1,inputArg2)
%DIRECTORIES Summary of this function goes here
%   Detailed explanation goes here

% Ensure the top‐level "tests" folder exists
rootDir = 'tests';
if ~exist(rootDir, 'dir')
    mkdir(rootDir);
    fprintf('Created folder: %s\n', rootDir);
end

% Loop until we successfully create (or override) the ID folder
while true
    % Ask user for an ID (string)
    ID = input('Enter an ID for the test folder: ', 's');
    
    % Build the full path for this ID
    idDir = fullfile(rootDir, ID);
    
    if ~exist(idDir, 'dir')
        % Doesn’t exist yet → create it and exit loop
        mkdir(idDir);
        fprintf('Created folder: %s\n', idDir);
        break;
    else
        % Already exists → ask what to do
        resp = input(sprintf('Folder "%s" already exists. Override it? [Y/N]: ', ID), 's');
        if strcmpi(resp, 'Y')
            % Remove and recreate
            rmdir(idDir, 's');    % 's' flag deletes all contents recursively
            mkdir(idDir);
            fprintf('Overridden folder: %s\n', idDir);
            break;
        else
            % User chose not to override → try again
            fprintf('OK, let''s pick another ID.\n\n');
        end
    end
end

end
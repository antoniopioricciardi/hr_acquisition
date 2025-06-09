function [outputArg1,outputArg2] = directories(inputArg1,inputArg2)
%DIRECTORIES Summary of this function goes here
%   Detailed explanation goes here

% Ensure the top‐level "tests" folder exists
rootDir = 'tests';
if ~exist(rootDir, 'dir')
    mkdir(rootDir);
    fprintf('Created folder: %s\n', rootDir);
end

% Ask user for an ID (string)
ID = input('Enter an ID for the test folder: ', 's');

% Build the full path for this ID
idDir = fullfile(rootDir, ID);
    
% Ensure the top‐level "tests" folder exists
rootDir = 'tests';
if ~exist(rootDir, 'dir')
    mkdir(rootDir);
    fprintf('Created folder: %s\n', rootDir);
else
    % Already exists → ask what to do
    promptStr = sprintf(...
        ['Folder "%s" already exists.\n' ...
         '[Y]es – override it;\n'       ...
         '[N]o – pick another ID;\n'    ...
         '[E]xit – cancel script.\n'    ...
         'Your choice [Y/N/E]: '], ID);
    resp = input(promptStr, 's');
    
    if strcmpi(resp, 'Y')
        % Remove and recreate
        rmdir(idDir, 's');    % 's' flag deletes all contents recursively
        mkdir(idDir);
        fprintf('Overridden folder: %s\n', idDir);
        
    elseif strcmpi(resp, 'E')
        % Exit script immediately
        fprintf('Exiting without creating or overriding any folder.\n');
        return;
        
    else
        % User chose not to override → try again
        fprintf('OK, let''s pick another ID (or press E to exit).\n\n');
        directories()
    end
end
return
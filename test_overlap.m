% Load the data from a2.mat and a1.mat
load('a2.mat', 'a2');
load('a1.mat', 'a1');

% Initialize a flag to indicate if a subset is found
subsetFound = false;

% Loop through each possible starting index in a2
for i = 1:length(a2) - 49
    % Get the subset from a2
    subset = a2(i:i+49);
    
    % Check if the subset is contained in a1
    [isContained, indexInA1] = containsSubset(a1, subset);
    if isContained
        subsetFound = true;
        fprintf('Subset found starting at index %d in a2 and at index %d in a1, ending at index %d in a1.\n', i, indexInA1, indexInA1 + length(subset) - 1);
        break;
    end
end

if ~subsetFound
    fprintf('No subset of length up to 50 from a2 is contained in a1.\n');
end

% Function to check if subset is contained in array
function [isContained, indexInA1] = containsSubset(array, subset)
    isContained = false;
    indexInA1 = -1;
    for j = 1:length(array) - length(subset) + 1
        if isequal(array(j:j+length(subset)-1), subset)
            isContained = true;
            indexInA1 = j;
            break;
        end
    end
end
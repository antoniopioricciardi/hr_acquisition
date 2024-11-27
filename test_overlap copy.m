% Load the .mat files
load('a1.mat');
load('a2.mat');

% Check if a1 and a2 have overlapping data
overlap = intersect(a1, a2);

if ~isempty(overlap)
    disp('a1 and a2 have overlapping data.');
else
    disp('a1 and a2 do not have overlapping data.');
end
% Find the indices of the overlapping data in a1 and a2
[~, idx_a1] = ismember(overlap, a1);
[~, idx_a2] = ismember(overlap, a2);

% Display the indices
disp('Indices of overlapping data in a1:');
disp(idx_a1);
disp('Indices of overlapping data in a2:');
disp(idx_a2);
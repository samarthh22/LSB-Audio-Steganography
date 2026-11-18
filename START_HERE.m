% START_HERE - Run this file directly in MATLAB after unzipping the folder.
% The full project is self-contained and requires no extra MATLAB toolbox.
projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'MATLAB'));
run_project();
run_tests();
verify_reference();
fprintf('\nALL DEFAULT-DEMO CHECKS COMPLETED. Open the outputs folder.\n');

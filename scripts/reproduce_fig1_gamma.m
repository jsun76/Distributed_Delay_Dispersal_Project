projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

params = barbara_default_parameters();
ensure_results_dirs(params);

shapeValues = [1 2 5 15];
meanDelay = 1;
filename = fullfile(params.figureDir, 'barbara_fig1_gamma_level1.png');

fig = plot_gamma_kernels(shapeValues, meanDelay, filename);
save(fullfile(params.rawDir, 'barbara_fig1_gamma_level1.mat'), ...
    'shapeValues', 'meanDelay');

fprintf('Saved %s\n', filename);

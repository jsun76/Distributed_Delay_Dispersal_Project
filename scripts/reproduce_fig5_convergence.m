projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

params = barbara_default_parameters();
ensure_results_dirs(params);

shapeValues = [1 2 3 4 5 6 8 10 12];
tauValues = [0.08 0.25 0.75 1.5 5.0];
phaseLags = 0.5 * pi;
sweepOptions = struct('totalTime', 900, 'sampleCount', 6000, 'verbose', true);

results = sweep_tau_p(shapeValues, tauValues, phaseLags, params, sweepOptions);

filename = fullfile(params.figureDir, 'barbara_fig5_convergence_level1.png');
fig = plot_convergence_rates(results, filename);
save(fullfile(params.processedDir, 'barbara_fig5_convergence_level1.mat'), ...
    'shapeValues', 'tauValues', 'phaseLags', 'results');

fprintf('Saved %s\n', filename);

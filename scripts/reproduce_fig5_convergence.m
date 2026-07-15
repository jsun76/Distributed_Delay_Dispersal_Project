projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

params = barbara_default_parameters();
ensure_results_dirs(params);

% Values read from Barbara's Figure 5 legends. Panels (a), (b), and (c)
% use the following pairs respectively.
% Figure 5 does not state its p grid. Reuse the nine integer p values that
% the manuscript explicitly lists for the adjacent Figure 4 sweep.
shapeValues = [1 2 3 4 5 6 8 10 12];
tauValues = [1.25 1.75 2.5 3.5 5.25 6.25];
phaseLags = 0.5 * pi;
sweepOptions = struct('totalTime', 1200, 'sampleCount', [], 'verbose', true);

results = sweep_tau_p(shapeValues, tauValues, phaseLags, params, sweepOptions);

filename = fullfile(params.figureDir, 'barbara_fig5_convergence_level1.png');
fig = plot_convergence_rates(results, filename);
save(fullfile(params.processedDir, 'barbara_fig5_convergence_level1.mat'), ...
    'shapeValues', 'tauValues', 'phaseLags', 'results');

fprintf('Saved %s\n', filename);

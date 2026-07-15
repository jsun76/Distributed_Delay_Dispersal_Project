projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

params = barbara_default_parameters();
ensure_results_dirs(params);

quickMode = true;

if quickMode
    shapeValues = [1 2 4 8 12];
    tauValues = linspace(0.05, params.singlePatchPeriod, 18);
    phaseLags = 0.5 * pi;
    sweepOptions = struct('totalTime', 500, 'sampleCount', 3500, 'verbose', true);
else
    shapeValues = [1 2 3 4 5 6 8 10 12];
    tauValues = unique([linspace(0.03, 0.5, 24), ...
        linspace(0.75, params.singlePatchPeriod, 30)]);
    phaseLags = [0.15 0.5 0.95] * pi;
    sweepOptions = struct('totalTime', 900, 'sampleCount', 6000, 'verbose', true);
end

results = sweep_tau_p(shapeValues, tauValues, phaseLags, params, sweepOptions);

filename = fullfile(params.figureDir, 'barbara_fig4_phase_regions_level1.png');
fig = plot_phase_regions(results, filename);
save(fullfile(params.processedDir, 'barbara_fig4_phase_regions_level1.mat'), ...
    'shapeValues', 'tauValues', 'phaseLags', 'quickMode', 'results');

fprintf('Saved %s\n', filename);

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

params = barbara_default_parameters();
ensure_results_dirs(params);

cases = struct('shape', {}, 'tau', {}, 'phaseLag', {}, 'label', {});
cases(1).shape = 15;
cases(1).tau = 5.0;
cases(1).phaseLag = 0;
cases(1).label = 'p=15, tau=5';
cases(2).shape = 15;
cases(2).tau = 1.5;
cases(2).phaseLag = pi;
cases(2).label = 'p=15, tau=1.5';
cases(3).shape = 15;
cases(3).tau = 0.38;
cases(3).phaseLag = 0.5 * pi;
cases(3).label = 'p=15, tau=0.38';

orbit = single_patch_limit_cycle(params);
simulations = cell(numel(cases), 1);
labels = cell(numel(cases), 1);

options = struct();
options.totalTime = 700;
options.sampleCount = 6000;
options.singlePatchOrbit = orbit;

for k = 1:numel(cases)
    options.initialPhaseLag = cases(k).phaseLag;
    simulations{k} = run_time_simulation(cases(k).shape, cases(k).tau, ...
        params, options);
    labels{k} = cases(k).label;
end

filename = fullfile(params.figureDir, 'barbara_fig2_orbits_level1.png');
fig = plot_orbits(simulations, labels, filename);
save(fullfile(params.rawDir, 'barbara_fig2_orbits_level1.mat'), ...
    'cases', 'simulations');

fprintf('Saved %s\n', filename);

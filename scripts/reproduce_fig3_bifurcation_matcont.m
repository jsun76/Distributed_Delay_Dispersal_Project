projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

params = barbara_default_parameters();
ensure_results_dirs(params);

options = struct();
options.quickMode = true;

results = run_barbara_fig3_continuation(params, options);

filename = fullfile(params.figureDir, 'barbara_fig3_bifurcation_matcont_level1.png');
fig = plot_fig3_bifurcation_diagrams(results, filename);

save(fullfile(params.processedDir, 'barbara_fig3_bifurcation_matcont_level1.mat'), ...
    'options', 'results', '-v7.3');

fprintf('Saved %s\n', filename);

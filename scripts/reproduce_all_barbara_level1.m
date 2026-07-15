projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectRoot, 'src')));

stepNames = {'Figure 1 gamma kernels', ...
    'Figure 2 representative orbits', ...
    'Figure 3 MatCont bifurcation diagrams', ...
    'Figure 4 phase-region sweep', ...
    'Figure 5 convergence-rate sweep'};
scriptNames = {'reproduce_fig1_gamma.m', ...
    'reproduce_fig2_orbits.m', ...
    'reproduce_fig3_bifurcation_matcont.m', ...
    'reproduce_fig4_phase_regions.m', ...
    'reproduce_fig5_convergence.m'};

for stepIdx = 1:numel(scriptNames)
    stepName = stepNames{stepIdx};
    scriptName = scriptNames{stepIdx};

    fprintf('[%s] Running %s...\n', current_time_label(), stepName);
    drawnow;
    stepTimer = tic;
    run_level1_script(projectRoot, scriptName);
    fprintf('[%s] Finished %s in %.1f seconds.\n', ...
        current_time_label(), stepName, toc(stepTimer));
    drawnow;
end

fprintf('Level 1 reproduction complete.\n');

function label = current_time_label()
label = char(datetime('now', 'Format', 'HH:mm:ss'));
end

function run_level1_script(projectRoot, scriptName)
run(fullfile(projectRoot, 'scripts', scriptName));
end

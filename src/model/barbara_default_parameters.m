function params = barbara_default_parameters()
%BARBARA_DEFAULT_PARAMETERS Parameters used in Gravel's Figures 2--5.

projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));

params = struct();
params.alpha = 0.35;
params.mu = 0.30;
params.epsilon = 0.10;
params.d = 0.001;
params.singlePatchPeriod = 7.34;
params.solver = 'ode15s';
params.RelTol = 1e-8;
params.AbsTol = 1e-10;
params.MaxStep = 0.05;
params.zeroDelayTolerance = 1e-10;
params.transientFraction = 0.60;
params.inPhaseTolerance = 0.15 * pi;
params.antiPhaseTolerance = 0.15 * pi;
params.minPhaseErrorForFit = 1e-5;
params.projectRoot = projectRoot;
params.figureDir = fullfile(projectRoot, 'results', 'figures');
params.rawDir = fullfile(projectRoot, 'results', 'raw');
params.processedDir = fullfile(projectRoot, 'results', 'processed');
end

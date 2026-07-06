function params = barbara_default_parameters(varargin)
%BARBARA_DEFAULT_PARAMETERS Parameters used in Barbara Gravel's report.
%
% The defaults follow the relaxation-like oscillation case:
% alpha = 0.35, mu = 0.3, epsilon = 0.1, d = 0.001.

modelDir = fileparts(mfilename('fullpath'));
srcDir = fileparts(modelDir);
projectRoot = fileparts(srcDir);

params = struct();
params.alpha = 0.35;
params.mu = 0.3;
params.epsilon = 0.1;
params.d = 0.001;
params.singlePatchPeriod = 7.34;

params.solver = 'ode15s';
params.RelTol = 1e-7;
params.AbsTol = 1e-9;
params.MaxStep = [];

params.zeroDelayTolerance = 1e-10;
params.transientFraction = 0.6;
params.inPhaseTolerance = 0.15 * pi;
params.antiPhaseTolerance = 0.15 * pi;
params.minPhaseErrorForFit = 1e-4;

params.projectRoot = projectRoot;
params.figureDir = fullfile(projectRoot, 'results', 'figures');
params.rawDir = fullfile(projectRoot, 'results', 'raw');
params.processedDir = fullfile(projectRoot, 'results', 'processed');

if mod(numel(varargin), 2) ~= 0
    error('barbara_default_parameters:NameValuePairs', ...
        'Overrides must be supplied as name-value pairs.');
end

for k = 1:2:numel(varargin)
    name = varargin{k};
    value = varargin{k + 1};
    if ~ischar(name)
        error('barbara_default_parameters:InvalidName', ...
            'Parameter names must be character vectors.');
    end
    params.(name) = value;
end
end

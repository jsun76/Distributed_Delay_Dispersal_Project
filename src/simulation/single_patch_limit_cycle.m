function orbit = single_patch_limit_cycle(params, options)
%SINGLE_PATCH_LIMIT_CYCLE Simulate the uncoupled oscillator.

if nargin < 1 || isempty(params)
    params = barbara_default_parameters();
end
if nargin < 2 || isempty(options)
    options = struct();
end

if isfield(options, 'initialState')
    z0 = options.initialState(:);
else
    z0 = [0.8; 1.0];
end

if isfield(options, 'totalTime')
    totalTime = options.totalTime;
else
    totalTime = 60 * params.singlePatchPeriod;
end

if isfield(options, 'sampleCount')
    sampleCount = options.sampleCount;
else
    sampleCount = 6000;
end

solverOptions = odeset('RelTol', params.RelTol, 'AbsTol', params.AbsTol);
if ~isempty(params.MaxStep)
    solverOptions = odeset(solverOptions, 'MaxStep', params.MaxStep);
end

solver = str2func(params.solver);
tspan = linspace(0, totalTime, sampleCount);
[t, z] = solver(@(time, state) single_patch_rhs(time, state, params), ...
    tspan, z0, solverOptions);

tailMask = t >= 0.5 * totalTime;
[peakTimes, peakValues] = find_local_maxima(t(tailMask), z(tailMask, 1), ...
    0.25 * params.singlePatchPeriod);

if numel(peakTimes) >= 3
    period = median(diff(peakTimes));
else
    period = params.singlePatchPeriod;
end

orbit = struct();
orbit.t = t;
orbit.h = z(:, 1);
orbit.p = z(:, 2);
orbit.period = period;
orbit.peakTimes = peakTimes;
orbit.peakValues = peakValues;
end

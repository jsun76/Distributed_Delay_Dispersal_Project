function sim = run_time_simulation(shape, tau, params, options)
%RUN_TIME_SIMULATION Integrate Barbara's two-patch gamma-delay ODE.

if nargin < 3 || isempty(params)
    params = barbara_default_parameters();
end
if nargin < 4 || isempty(options)
    options = struct();
end

if isfield(options, 'totalTime')
    totalTime = options.totalTime;
else
    totalTime = 700;
end

if isfield(options, 'sampleCount')
    sampleCount = options.sampleCount;
else
    sampleCount = 5000;
end

if isfield(options, 'initialState')
    z0 = options.initialState(:);
else
    if isfield(options, 'initialPhaseLag')
        phaseLag = options.initialPhaseLag;
    else
        phaseLag = 0.5 * pi;
    end
    if isfield(options, 'singlePatchOrbit')
        orbit = options.singlePatchOrbit;
    else
        orbit = single_patch_limit_cycle(params);
    end
    z0 = make_two_patch_initial_state(shape, tau, params, phaseLag, orbit);
end

solverOptions = odeset('RelTol', params.RelTol, 'AbsTol', params.AbsTol);
if ~isempty(params.MaxStep)
    solverOptions = odeset(solverOptions, 'MaxStep', params.MaxStep);
end

tspan = linspace(0, totalTime, sampleCount);
solver = str2func(params.solver);
[t, z] = solver(@(time, state) two_patch_gamma_delay_rhs(time, state, ...
    shape, tau, params), tspan, z0, solverOptions);

idx = gamma_chain_indices(shape);
sim = struct();
sim.shape = shape;
sim.tau = tau;
sim.variance = tau ^ 2 / shape;
sim.t = t;
sim.z = z;
sim.h1 = z(:, idx.h1);
sim.p1 = z(:, idx.p1);
sim.h2 = z(:, idx.h2);
sim.p2 = z(:, idx.p2);
sim.y1 = z(:, idx.y1);
sim.y2 = z(:, idx.y2);
sim.initialState = z0;
sim.params = params;
end

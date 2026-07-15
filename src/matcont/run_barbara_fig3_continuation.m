function results = run_barbara_fig3_continuation(params, options)
%RUN_BARBARA_FIG3_CONTINUATION Continue Figure 3 phase-locking branches.

if nargin < 1 || isempty(params)
    params = barbara_default_parameters();
end
if nargin < 2 || isempty(options)
    options = struct();
end

options = with_default_options(options, params);
ensure_results_dirs(params);

orbit = single_patch_limit_cycle(params);
seeds = build_seed_cycles(params, orbit, options);

cleanupObj = setup_matcont(params.projectRoot); %#ok<NASGU>
branches = repmat(struct('shape', [], 'seedTau', [], 'label', '', ...
    'points', [], 'specialPoints', [], 'runs', [], ...
    'coverageComplete', false), numel(seeds), 1);

for k = 1:numel(seeds)
    fprintf('MatCont Figure 3 branch %d/%d: p=%d, %s seed tau=%.4g\n', ...
        k, numel(seeds), seeds(k).shape, seeds(k).label, seeds(k).tau);
    drawnow;
    try
        branches(k) = continue_barbara_seed_cycle(seeds(k), params, options);
    catch err
        warning('run_barbara_fig3_continuation:BranchFailed', ...
            'Branch failed for p=%d, %s, tau=%.4g: %s', ...
            seeds(k).shape, seeds(k).label, seeds(k).tau, err.message);
        branches(k).shape = seeds(k).shape;
        branches(k).seedTau = seeds(k).tau;
        branches(k).label = seeds(k).label;
        branches(k).points = [];
        branches(k).specialPoints = [];
        branches(k).runs = [];
        branches(k).coverageComplete = false;
    end
end

results = struct();
results.params = params;
results.options = options;
results.seeds = rmfield(seeds, 'cycle');
results.branches = branches;
results.caption = ['MatCont continuation of phase-locked periodic orbits ', ...
    'for Barbara Figure 3. Stability is inferred from Floquet multipliers.'];
end

function options = with_default_options(options, params)
if ~isfield(options, 'quickMode')
    options.quickMode = false;
end
if ~isfield(options, 'shapeValues')
    options.shapeValues = [2 10 15];
end
if ~isfield(options, 'tauMin')
    options.tauMin = 0.01;
end
if ~isfield(options, 'tauMax')
    options.tauMax = params.singlePatchPeriod;
end
if ~isfield(options, 'zoomTauMax')
    options.zoomTauMax = 0.6;
end
if ~isfield(options, 'cycleTolerance')
    options.cycleTolerance = 1e-6;
end
if ~isfield(options, 'multiplierTolerance')
    options.multiplierTolerance = 1e-3;
end
if ~isfield(options, 'funTolerance')
    options.funTolerance = 1e-8;
end
if ~isfield(options, 'varTolerance')
    options.varTolerance = 1e-8;
end
if ~isfield(options, 'testTolerance')
    options.testTolerance = 1e-6;
end
if ~isfield(options, 'refineSeeds')
    options.refineSeeds = true;
end
if ~isfield(options, 'coverageTolerance')
    options.coverageTolerance = 0.05;
end

if options.quickMode
    defaults = struct('ntst', 40, 'ncol', 4, 'maxNumPoints', 140, ...
        'initStepSize', 0.002, 'maxStepSize', 0.5, 'minStepSize', 1e-6, ...
        'adapt', 3, 'seedTotalTime', 500, 'seedSampleCount', 4500, ...
        'cycleSampleCount', 1000, 'seedTauTolerance', 0.03, ...
        'bvpRelTol', 1e-8, 'bvpAbsTol', 1e-10);
else
    defaults = struct('ntst', 60, 'ncol', 4, 'maxNumPoints', 350, ...
        'initStepSize', 0.001, 'maxStepSize', 0.75, 'minStepSize', 1e-7, ...
        'adapt', 3, 'seedTotalTime', 800, 'seedSampleCount', 6500, ...
        'cycleSampleCount', 1600, 'seedTauTolerance', 0.01, ...
        'bvpRelTol', 1e-10, 'bvpAbsTol', 1e-12);
end

names = fieldnames(defaults);
for k = 1:numel(names)
    name = names{k};
    if ~isfield(options, name)
        options.(name) = defaults.(name);
    end
end
end

function seeds = build_seed_cycles(params, orbit, options)
seedTemplates = struct('label', {}, 'tau', {}, 'phaseLag', {});
seedTemplates(1).label = 'in-phase';
seedTemplates(1).tau = 0.05;
seedTemplates(1).phaseLag = 0;
seedTemplates(2).label = 'out-of-phase';
seedTemplates(2).tau = 0.30;
seedTemplates(2).phaseLag = 0.5 * pi;
seedTemplates(3).label = 'anti-phase';
seedTemplates(3).tau = 1.5;
seedTemplates(3).phaseLag = pi;

seeds = repmat(struct('shape', [], 'label', '', 'tau', [], 'phaseLag', [], ...
    'cycle', [], 'seedClassification', '', 'seedPhase', [], ...
    'rawClosure', NaN, 'bvpResidual', NaN, 'refined', false), ...
    numel(options.shapeValues) * numel(seedTemplates), 1);

idx = 0;
for pIdx = 1:numel(options.shapeValues)
    shape = options.shapeValues(pIdx);
    for branchIdx = 1:numel(seedTemplates)
        template = seedTemplates(branchIdx);
        seedTau = template.tau;
        if strcmp(template.label, 'out-of-phase') && shape == 15
            seedTau = 0.38;
        end

        idx = idx + 1;
        fprintf('Preparing Figure 3 seed %d/%d: p=%d, %s, tau=%.4g\n', ...
            idx, numel(seeds), shape, template.label, seedTau);
        drawnow;

        simOptions = struct();
        simOptions.totalTime = options.seedTotalTime;
        simOptions.sampleCount = options.seedSampleCount;
        simOptions.initialPhaseLag = template.phaseLag;
        simOptions.singlePatchOrbit = orbit;

        sim = run_time_simulation(shape, seedTau, params, simOptions);
        cycle = extract_periodic_cycle(sim, params, options.cycleSampleCount);
        rawClosure = max(abs(cycle.y(end, :) - cycle.y(1, :)));
        if options.refineSeeds
            bvpOptions = struct('sampleCount', options.cycleSampleCount, ...
                'relTol', options.bvpRelTol, 'absTol', options.bvpAbsTol);
            cycle = refine_periodic_cycle_bvp(cycle, shape, seedTau, ...
                params, bvpOptions);
        end
        phaseInfo = phase_difference_series(sim.t, sim.h1, sim.h2, params);

        seeds(idx).shape = shape;
        seeds(idx).label = template.label;
        seeds(idx).tau = seedTau;
        seeds(idx).phaseLag = template.phaseLag;
        seeds(idx).cycle = cycle;
        seeds(idx).seedPhase = phaseInfo.finalPhase;
        seeds(idx).seedClassification = classify_phase_locking(phaseInfo.finalPhase, params);
        seeds(idx).rawClosure = rawClosure;
        if isfield(cycle, 'bvpResidual')
            seeds(idx).bvpResidual = cycle.bvpResidual;
            seeds(idx).refined = true;
        end
    end
end
end





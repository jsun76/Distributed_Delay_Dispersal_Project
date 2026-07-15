function branch = continue_barbara_seed_cycle(seed, params, options)
%CONTINUE_BARBARA_SEED_CYCLE Continue one seeded phase-locked cycle in tau.

par = [params.alpha; params.mu; params.epsilon; params.d; seed.tau];
activeParam = 5;

[x0, v0] = initOrbLC(@barbara_matcont_odefile, seed.cycle.t, seed.cycle.y, ...
    par, activeParam, options.ntst, options.ncol, options.cycleTolerance);

runs = repmat(struct('x', [], 'v', [], 's', [], 'h', [], 'f', [], ...
    'backward', [], 'error', '', 'seedTauDrift', NaN, ...
    'initialCorrectionDrift', NaN), 2, 1);
points = [];
specialPoints = [];

for directionIdx = 1:2
    backward = directionIdx == 2;
    try
        directionX0 = x0;
        directionV0 = v0;
        expectedTau = seed.tau;
        if backward && ~isempty(runs(1).x)
            % Reinitialize from MatCont's already corrected forward anchor.
            % Correcting the raw simulation independently with Backward=1
            % can select a distant point on this weakly coupled manifold.
            backPar = par;
            backPar(activeParam) = runs(1).x(end, 1);
            [directionX0, directionV0] = init_LC_LC( ...
                @barbara_matcont_odefile, runs(1).x, runs(1).v, ...
                runs(1).s(1), backPar, activeParam, ...
                options.ntst, options.ncol);
            expectedTau = runs(1).x(end, 1);
        end
        runs(directionIdx) = run_one_direction(directionX0, directionV0, ...
            backward, options, expectedTau);
        runs(directionIdx).seedTauDrift = ...
            abs(runs(directionIdx).x(end, 1) - seed.tau);
        if isempty(runs(directionIdx).x)
            continue;
        end
        extracted = extract_matcont_lc_run(runs(directionIdx).x, ...
            runs(directionIdx).s, runs(directionIdx).f, seed.shape, ...
            seed.label, options, directionIdx);
        points = [points; extracted.points]; %#ok<AGROW>
        specialPoints = [specialPoints; extracted.specialPoints]; %#ok<AGROW>
    catch err
        runs(directionIdx).backward = backward;
        runs(directionIdx).error = err.message;
        warning('continue_barbara_seed_cycle:DirectionFailed', ...
            '%s direction failed for p=%d, %s, tau=%.4g: %s', ...
            direction_name(backward), seed.shape, seed.label, seed.tau, err.message);
    end
end

points = filter_and_sort_points(points, options.tauMin, options.tauMax);
specialPoints = filter_special_points(specialPoints, options.tauMin, options.tauMax);

coverageComplete = true;
if any(strcmp(seed.label, {'in-phase', 'anti-phase'}))
    coverageComplete = ~isempty(points) && ...
        min([points.tau]) <= options.tauMin + options.coverageTolerance && ...
        max([points.tau]) >= options.tauMax - options.coverageTolerance;
    if ~coverageComplete
        warning('continue_barbara_seed_cycle:IncompleteCoverage', ...
            ['p=%d %s branch covers tau=[%.4g, %.4g], not the requested ', ...
            '[%.4g, %.4g]. Increase MaxNumPoints/MaxStepsize.'], ...
            seed.shape, seed.label, min_or_nan(points), max_or_nan(points), ...
            options.tauMin, options.tauMax);
    end
end

branch = struct();
branch.shape = seed.shape;
branch.seedTau = seed.tau;
branch.label = seed.label;
branch.points = points;
branch.specialPoints = specialPoints;
branch.runs = runs;
branch.coverageComplete = coverageComplete;
end

function runData = run_one_direction(x0, v0, backward, options, expectedTau)
opt = contset;
opt = contset(opt, 'Singularities', 1);
opt = contset(opt, 'Multipliers', 1);
opt = contset(opt, 'Adapt', options.adapt);
opt = contset(opt, 'MaxNumPoints', options.maxNumPoints);
opt = contset(opt, 'InitStepsize', options.initStepSize);
opt = contset(opt, 'MaxStepsize', options.maxStepSize);
opt = contset(opt, 'MinStepsize', options.minStepSize);
opt = contset(opt, 'FunTolerance', options.funTolerance);
opt = contset(opt, 'VarTolerance', options.varTolerance);
opt = contset(opt, 'TestTolerance', options.testTolerance);
opt = contset(opt, 'Backward', double(backward));

[x, v, s, h, f] = cont(@limitcycle, x0, v0, opt);
initialCorrectionDrift = abs(x(end, 1) - expectedTau);
if initialCorrectionDrift > options.seedTauTolerance
    error('continue_barbara_seed_cycle:SeedDrift', ...
        ['MatCont corrected the requested tau=%.8g anchor to tau=%.8g ', ...
        '(drift %.3g > tolerance %.3g). Refine the seed or increase ntst.'], ...
        expectedTau, x(end, 1), initialCorrectionDrift, options.seedTauTolerance);
end

runData = struct();
runData.x = x;
runData.v = v;
runData.s = s;
runData.h = h;
runData.f = f;
runData.backward = backward;
runData.error = '';
runData.seedTauDrift = initialCorrectionDrift;
runData.initialCorrectionDrift = initialCorrectionDrift;
end

function points = filter_and_sort_points(points, tauMin, tauMax)
if isempty(points)
    return;
end
mask = [points.tau] >= tauMin & [points.tau] <= tauMax & isfinite([points.phase]);
points = points(mask);
if isempty(points)
    return;
end
keep = true(size(points));
for k = 1:numel(points)
    if ~keep(k)
        continue;
    end
    for j = (k + 1):numel(points)
        sameLocation = abs(points(j).tau - points(k).tau) < 1e-7 && ...
            abs(points(j).phase - points(k).phase) < 1e-5 && ...
            abs(points(j).period - points(k).period) < 1e-5;
        if sameLocation
            keep(j) = false;
        end
    end
end
points = points(keep);
end

function value = min_or_nan(points)
if isempty(points)
    value = NaN;
else
    value = min([points.tau]);
end
end

function value = max_or_nan(points)
if isempty(points)
    value = NaN;
else
    value = max([points.tau]);
end
end

function specialPoints = filter_special_points(specialPoints, tauMin, tauMax)
if isempty(specialPoints)
    return;
end
mask = [specialPoints.tau] >= tauMin & [specialPoints.tau] <= tauMax;
specialPoints = specialPoints(mask);
end

function name = direction_name(backward)
if backward
    name = 'backward';
else
    name = 'forward';
end
end


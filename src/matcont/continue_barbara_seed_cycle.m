function branch = continue_barbara_seed_cycle(seed, params, options)
%CONTINUE_BARBARA_SEED_CYCLE Continue one seeded phase-locked cycle in tau.

par = [params.alpha; params.mu; params.epsilon; params.d; seed.tau];
activeParam = 5;

[x0, v0] = initOrbLC(@barbara_matcont_odefile, seed.cycle.t, seed.cycle.y, ...
    par, activeParam, options.ntst, options.ncol, options.cycleTolerance);

runs = repmat(struct('x', [], 'v', [], 's', [], 'h', [], 'f', [], ...
    'backward', [], 'error', ''), 2, 1);
points = [];
specialPoints = [];

for directionIdx = 1:2
    backward = directionIdx == 2;
    try
        runs(directionIdx) = run_one_direction(x0, v0, backward, options);
        if isempty(runs(directionIdx).x)
            continue;
        end
        extracted = extract_matcont_lc_run(runs(directionIdx).x, ...
            runs(directionIdx).s, runs(directionIdx).f, seed.shape, ...
            seed.label, options);
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

branch = struct();
branch.shape = seed.shape;
branch.seedTau = seed.tau;
branch.label = seed.label;
branch.points = points;
branch.specialPoints = specialPoints;
branch.runs = runs;
end

function runData = run_one_direction(x0, v0, backward, options)
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

runData = struct();
runData.x = x;
runData.v = v;
runData.s = s;
runData.h = h;
runData.f = f;
runData.backward = backward;
runData.error = '';
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
[~, order] = sort([points.tau]);
points = points(order);

keep = true(size(points));
lastTau = NaN;
for k = 1:numel(points)
    if isfinite(lastTau) && abs(points(k).tau - lastTau) < 1e-5
        keep(k) = false;
    else
        lastTau = points(k).tau;
    end
end
points = points(keep);
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


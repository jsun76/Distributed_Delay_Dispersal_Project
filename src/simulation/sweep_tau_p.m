function results = sweep_tau_p(shapeValues, tauValues, phaseLags, params, options)
%SWEEP_TAU_P Run simulation-based phase classification over p and tau.

if nargin < 4 || isempty(params)
    params = barbara_default_parameters();
end
if nargin < 5 || isempty(options)
    options = struct();
end
if nargin < 3 || isempty(phaseLags)
    phaseLags = 0.5 * pi;
end

if isfield(options, 'verbose')
    verbose = options.verbose;
else
    verbose = false;
end

if isfield(options, 'totalTime')
    simOptions.totalTime = options.totalTime;
else
    simOptions.totalTime = 700;
end

if isfield(options, 'sampleCount')
    simOptions.sampleCount = options.sampleCount;
else
    simOptions.sampleCount = 5000;
end

orbit = single_patch_limit_cycle(params);
simOptions.singlePatchOrbit = orbit;

emptyRecord = struct('shape', [], 'tau', [], 'variance', [], ...
    'initialPhaseLag', [], 'finalPhase', [], 'classification', '', ...
    'period', [], 'convergenceRate', [], 'convergenceRSquared', [], ...
    'amplitudeH1', [], 'amplitudeH2', []);
results = repmat(emptyRecord, numel(shapeValues) * numel(tauValues) * ...
    numel(phaseLags), 1);

recordIdx = 0;
totalRuns = numel(results);

for pIdx = 1:numel(shapeValues)
    shape = shapeValues(pIdx);
    for tauIdx = 1:numel(tauValues)
        tau = tauValues(tauIdx);
        for lagIdx = 1:numel(phaseLags)
            recordIdx = recordIdx + 1;
            simOptions.initialPhaseLag = phaseLags(lagIdx);

            if verbose
                fprintf('Level 1 sweep %d/%d: p=%g, tau=%.4g, lag=%.3g*pi\n', ...
                    recordIdx, totalRuns, shape, tau, phaseLags(lagIdx) / pi);
            end

            sim = run_time_simulation(shape, tau, params, simOptions);
            phaseInfo = phase_difference_series(sim.t, sim.h1, sim.h2, params);
            classLabel = classify_phase_locking(phaseInfo.finalPhase, params);
            rateInfo = estimate_convergence_rate(sim.t, sim.h1, sim.h2, params);

            tailMask = sim.t >= sim.t(1) + params.transientFraction * ...
                (sim.t(end) - sim.t(1));

            results(recordIdx).shape = shape;
            results(recordIdx).tau = tau;
            results(recordIdx).variance = sim.variance;
            results(recordIdx).initialPhaseLag = phaseLags(lagIdx);
            results(recordIdx).finalPhase = phaseInfo.finalPhase;
            results(recordIdx).classification = classLabel;
            results(recordIdx).period = phaseInfo.period;
            results(recordIdx).convergenceRate = rateInfo.rate;
            results(recordIdx).convergenceRSquared = rateInfo.rSquared;
            results(recordIdx).amplitudeH1 = max(sim.h1(tailMask)) - min(sim.h1(tailMask));
            results(recordIdx).amplitudeH2 = max(sim.h2(tailMask)) - min(sim.h2(tailMask));
        end
    end
end
end

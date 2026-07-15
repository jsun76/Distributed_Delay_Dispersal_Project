function cycle = extract_periodic_cycle(sim, params, sampleCount)
%EXTRACT_PERIODIC_CYCLE Extract one closed-looking period from a simulation.

if nargin < 3 || isempty(sampleCount)
    sampleCount = 900;
end

startTime = sim.t(1) + params.transientFraction * (sim.t(end) - sim.t(1));
mask = sim.t >= startTime;
roughSeparation = 0.25 * params.singlePatchPeriod;
[peakTimes, ~] = find_local_maxima(sim.t(mask), sim.h1(mask), roughSeparation);

if numel(peakTimes) >= 2
    t0 = peakTimes(end - 1);
    t1 = peakTimes(end);
else
    t1 = sim.t(end);
    t0 = t1 - params.singlePatchPeriod;
end

if t0 < sim.t(1) || t1 <= t0
    error('extract_periodic_cycle:InvalidWindow', ...
        'Could not extract a valid final-period window.');
end

queryTimes = linspace(t0, t1, sampleCount).';
y = interp1(sim.t, sim.z, queryTimes, 'pchip');

cycle = struct();
cycle.t = queryTimes - queryTimes(1);
cycle.y = y;
cycle.period = cycle.t(end);
cycle.absoluteWindow = [t0 t1];
end

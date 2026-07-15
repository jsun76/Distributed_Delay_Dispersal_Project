function refined = refine_periodic_cycle_bvp(cycle, shape, tau, params, options)
%REFINE_PERIODIC_CYCLE_BVP Correct a simulated cycle at fixed tau.
%
% initOrbLC treats tau as free during its first Newton correction. A merely
% approximate simulated orbit can therefore move a long way in tau before
% continuation even starts. This fixed-parameter BVP first corrects the
% state profile and period, leaving MatCont only a small residual.

if nargin < 5 || isempty(options)
    options = struct();
end
if ~isfield(options, 'sampleCount')
    options.sampleCount = size(cycle.y, 1);
end
if ~isfield(options, 'relTol')
    options.relTol = 1e-7;
end
if ~isfield(options, 'absTol')
    options.absTol = 1e-9;
end

s = cycle.t(:) / cycle.period;
[s, uniqueIdx] = unique(s, 'stable');
y = cycle.y(uniqueIdx, :).';
y(:, end) = y(:, 1);

guess = bvpinit(s.', @initial_guess, cycle.period);
bvpOptions = bvpset('RelTol', options.relTol, 'AbsTol', options.absTol, ...
    'NMax', 20000, 'Stats', 'off');
solution = bvp4c(@scaled_rhs, @periodic_bc, guess, bvpOptions);

query = linspace(0, 1, options.sampleCount);
period = solution.parameters(1);
profile = deval(solution, query).';
profile(end, :) = profile(1, :);

refined = cycle;
refined.t = query(:) * period;
refined.y = profile;
refined.period = period;
refined.bvpResidual = max(abs(solution.stats.maxres));

    function state = initial_guess(queryPoint)
        state = interp1(s, y.', queryPoint, 'pchip').';
    end

    function dyds = scaled_rhs(~, state, orbitPeriod)
        dyds = orbitPeriod * two_patch_gamma_delay_rhs([], state, ...
            shape, tau, params);
    end

    function residual = periodic_bc(left, right, ~)
        vectorField = two_patch_gamma_delay_rhs([], left, shape, tau, params);
        % extract_periodic_cycle starts at an h1 maximum. This scalar phase
        % condition removes the neutral time-translation direction.
        residual = [left - right; vectorField(1)];
    end
end

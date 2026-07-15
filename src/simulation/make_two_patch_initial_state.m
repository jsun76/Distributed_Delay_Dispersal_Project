function z0 = make_two_patch_initial_state(shape, tau, params, phaseLag, orbit)
%MAKE_TWO_PATCH_INITIAL_STATE Sample two patches from the limit cycle.
%
% phaseLag is in radians. A phaseLag of 0 starts near in-phase; pi starts
% near anti-phase.

if nargin < 3 || isempty(params)
    params = barbara_default_parameters();
end
if nargin < 4 || isempty(phaseLag)
    phaseLag = 0.5 * pi;
end
if nargin < 5 || isempty(orbit)
    orbit = single_patch_limit_cycle(params);
end

period = orbit.period;
lagTime = mod(phaseLag, 2 * pi) / (2 * pi) * period;
anchorTime = orbit.t(end) - 0.25 * period;
otherTime = anchorTime - lagTime;

if otherTime < orbit.t(1)
    otherTime = otherTime + period;
end

h1 = interp1(orbit.t, orbit.h, anchorTime, 'pchip');
p1 = interp1(orbit.t, orbit.p, anchorTime, 'pchip');
h2 = interp1(orbit.t, orbit.h, otherTime, 'pchip');
p2 = interp1(orbit.t, orbit.p, otherTime, 'pchip');

z0 = gamma_chain_initial_state(h1, p1, h2, p2, shape);

if tau <= params.zeroDelayTolerance
    return;
end
end

function dzdt = two_patch_gamma_delay_rhs(~, z, shape, tau, params)
%TWO_PATCH_GAMMA_DELAY_RHS Two-patch ODE from the linear chain trick.
%
% Prey disperse between patches with gamma-distributed travel times. The
% shape parameter must be an integer so the distributed delay can be written
% as a finite ODE chain.

idx = gamma_chain_indices(shape);

h1 = z(idx.h1);
p1 = z(idx.p1);
h2 = z(idx.h2);
p2 = z(idx.p2);
y1 = z(idx.y1);
y2 = z(idx.y2);

if tau <= params.zeroDelayTolerance
    delayedH1 = h1;
    delayedH2 = h2;
    dy1dt = zeros(shape, 1);
    dy2dt = zeros(shape, 1);
else
    chainRate = shape / tau;
    delayedH1 = y1(end);
    delayedH2 = y2(end);

    dy1dt = zeros(shape, 1);
    dy2dt = zeros(shape, 1);
    dy1dt(1) = chainRate * (h1 - y1(1));
    dy2dt(1) = chainRate * (h2 - y2(1));

    for k = 2:shape
        dy1dt(k) = chainRate * (y1(k - 1) - y1(k));
        dy2dt(k) = chainRate * (y2(k - 1) - y2(k));
    end
end

local1 = h1 * (1 - params.alpha * h1) - p1 * h1 / (1 + h1);
local2 = h2 * (1 - params.alpha * h2) - p2 * h2 / (1 + h2);

dh1dt = local1 / params.epsilon + params.d * (delayedH2 - h1);
dp1dt = p1 * h1 / (1 + h1) - params.mu * p1;
dh2dt = local2 / params.epsilon + params.d * (delayedH1 - h2);
dp2dt = p2 * h2 / (1 + h2) - params.mu * p2;

dzdt = zeros(idx.n, 1);
dzdt(idx.h1) = dh1dt;
dzdt(idx.p1) = dp1dt;
dzdt(idx.h2) = dh2dt;
dzdt(idx.p2) = dp2dt;
dzdt(idx.y1) = dy1dt;
dzdt(idx.y2) = dy2dt;
end

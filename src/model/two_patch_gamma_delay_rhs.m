function dzdt = two_patch_gamma_delay_rhs(~, z, shape, tau, params)
%TWO_PATCH_GAMMA_DELAY_RHS Gravel's equation (11), via linear chains.
idx = gamma_chain_indices(shape);
z = z(:);
if numel(z) ~= idx.n
    error('two_patch_gamma_delay_rhs:StateSize', ...
        'Expected %d states for p=%d, received %d.', idx.n, shape, numel(z));
end
h1 = z(idx.h1);
p1 = z(idx.p1);
h2 = z(idx.h2);
p2 = z(idx.p2);
if tau <= params.zeroDelayTolerance
    delayedH1 = h1;
    delayedH2 = h2;
else
    delayedH1 = z(idx.y1(end));
    delayedH2 = z(idx.y2(end));
end
local1 = h1 * (1 - params.alpha * h1) - p1 * h1 / (1 + h1);
local2 = h2 * (1 - params.alpha * h2) - p2 * h2 / (1 + h2);
dzdt = zeros(idx.n, 1);
dzdt(idx.h1) = local1 / params.epsilon + params.d * (delayedH2 - h1);
dzdt(idx.p1) = p1 * h1 / (1 + h1) - params.mu * p1;
dzdt(idx.h2) = local2 / params.epsilon + params.d * (delayedH1 - h2);
dzdt(idx.p2) = p2 * h2 / (1 + h2) - params.mu * p2;
if tau > params.zeroDelayTolerance
    rate = shape / tau;
    dzdt(idx.y1(1)) = rate * (h1 - z(idx.y1(1)));
    dzdt(idx.y2(1)) = rate * (h2 - z(idx.y2(1)));
    for k = 2:shape
        dzdt(idx.y1(k)) = rate * (z(idx.y1(k - 1)) - z(idx.y1(k)));
        dzdt(idx.y2(k)) = rate * (z(idx.y2(k - 1)) - z(idx.y2(k)));
    end
end
end

function out = barbara_matcont_odefile
%BARBARA_MATCONT_ODEFILE MatCont wrapper for the two-patch gamma-chain ODE.

out{1} = @init;
out{2} = @fun_eval;
out{3} = @jacobian;
out{4} = @jacobianp;
out{5} = [];
out{6} = [];
out{7} = [];
out{8} = [];
out{9} = [];
end

function dzdt = fun_eval(~, z, alpha, mu, epsilon, dispersal, tau)
shape = infer_shape(z);
params = make_params(alpha, mu, epsilon, dispersal);
dzdt = two_patch_gamma_delay_rhs([], z, shape, tau, params);
end

function jac = jacobian(~, z, alpha, mu, epsilon, dispersal, tau)
shape = infer_shape(z);
idx = gamma_chain_indices(shape);
jac = zeros(idx.n, idx.n);

h1 = z(idx.h1);
p1 = z(idx.p1);
h2 = z(idx.h2);
p2 = z(idx.p2);

jac(idx.h1, idx.h1) = (1 - 2 * alpha * h1 - p1 / (1 + h1) ^ 2) / epsilon - dispersal;
jac(idx.h1, idx.p1) = -h1 / ((1 + h1) * epsilon);
jac(idx.p1, idx.h1) = p1 / (1 + h1) ^ 2;
jac(idx.p1, idx.p1) = h1 / (1 + h1) - mu;

jac(idx.h2, idx.h2) = (1 - 2 * alpha * h2 - p2 / (1 + h2) ^ 2) / epsilon - dispersal;
jac(idx.h2, idx.p2) = -h2 / ((1 + h2) * epsilon);
jac(idx.p2, idx.h2) = p2 / (1 + h2) ^ 2;
jac(idx.p2, idx.p2) = h2 / (1 + h2) - mu;

if tau <= 1e-10
    jac(idx.h1, idx.h2) = jac(idx.h1, idx.h2) + dispersal;
    jac(idx.h2, idx.h1) = jac(idx.h2, idx.h1) + dispersal;
else
    chainRate = shape / tau;
    jac(idx.h1, idx.y2(end)) = jac(idx.h1, idx.y2(end)) + dispersal;
    jac(idx.h2, idx.y1(end)) = jac(idx.h2, idx.y1(end)) + dispersal;

    jac(idx.y1(1), idx.h1) = chainRate;
    jac(idx.y1(1), idx.y1(1)) = -chainRate;
    jac(idx.y2(1), idx.h2) = chainRate;
    jac(idx.y2(1), idx.y2(1)) = -chainRate;

    for k = 2:shape
        jac(idx.y1(k), idx.y1(k - 1)) = chainRate;
        jac(idx.y1(k), idx.y1(k)) = -chainRate;
        jac(idx.y2(k), idx.y2(k - 1)) = chainRate;
        jac(idx.y2(k), idx.y2(k)) = -chainRate;
    end
end
end

function jacp = jacobianp(~, z, alpha, ~, epsilon, ~, tau)
shape = infer_shape(z);
idx = gamma_chain_indices(shape);
jacp = zeros(idx.n, 5);

h1 = z(idx.h1);
p1 = z(idx.p1);
h2 = z(idx.h2);
p2 = z(idx.p2);
y1 = z(idx.y1);
y2 = z(idx.y2);

localNumerator1 = h1 * (1 - alpha * h1) - p1 * h1 / (1 + h1);
localNumerator2 = h2 * (1 - alpha * h2) - p2 * h2 / (1 + h2);

jacp(idx.h1, 1) = -h1 ^ 2 / epsilon;
jacp(idx.h2, 1) = -h2 ^ 2 / epsilon;
jacp(idx.p1, 2) = -p1;
jacp(idx.p2, 2) = -p2;
jacp(idx.h1, 3) = -localNumerator1 / epsilon ^ 2;
jacp(idx.h2, 3) = -localNumerator2 / epsilon ^ 2;

if tau <= 1e-10
    delayedH1 = h1;
    delayedH2 = h2;
else
    delayedH1 = y1(end);
    delayedH2 = y2(end);
end
jacp(idx.h1, 4) = delayedH2 - h1;
jacp(idx.h2, 4) = delayedH1 - h2;

if tau > 1e-10
    rateTauDerivative = -shape / tau ^ 2;
    jacp(idx.y1(1), 5) = rateTauDerivative * (h1 - y1(1));
    jacp(idx.y2(1), 5) = rateTauDerivative * (h2 - y2(1));
    for k = 2:shape
        jacp(idx.y1(k), 5) = rateTauDerivative * (y1(k - 1) - y1(k));
        jacp(idx.y2(k), 5) = rateTauDerivative * (y2(k - 1) - y2(k));
    end
end
end

function [tspan, y0, options] = init
params = barbara_default_parameters();
shape = 2;
y0 = gamma_chain_initial_state(0.8, 1.0, 0.8, 1.0, shape);
tspan = [0 params.singlePatchPeriod];
options = odeset();
end

function params = make_params(alpha, mu, epsilon, dispersal)
params = struct();
params.alpha = alpha;
params.mu = mu;
params.epsilon = epsilon;
params.d = dispersal;
params.zeroDelayTolerance = 1e-10;
end

function shape = infer_shape(z)
shape = (numel(z) - 4) / 2;
if shape < 1 || shape ~= round(shape)
    error('barbara_matcont_odefile:InvalidStateSize', ...
        'The state length must be 4 + 2*p for integer p.');
end
end



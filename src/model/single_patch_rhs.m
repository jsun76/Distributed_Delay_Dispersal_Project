function dzdt = single_patch_rhs(~, z, params)
%SINGLE_PATCH_RHS Nondimensional Rosenzweig--MacArthur equations.
h = z(1);
p = z(2);
localPrey = h * (1 - params.alpha * h) - p * h / (1 + h);
dzdt = [localPrey / params.epsilon; ...
    p * h / (1 + h) - params.mu * p];
end

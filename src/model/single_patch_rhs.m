function dzdt = single_patch_rhs(~, z, params)
%SINGLE_PATCH_RHS Nondimensional Rosenzweig-MacArthur predator-prey model.

h = z(1);
pred = z(2);

dhdt = (h * (1 - params.alpha * h) - pred * h / (1 + h)) / params.epsilon;
dpdt = pred * h / (1 + h) - params.mu * pred;

dzdt = [dhdt; dpdt];
end

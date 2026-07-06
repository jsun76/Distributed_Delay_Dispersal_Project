function z0 = gamma_chain_initial_state(h1, p1, h2, p2, shape)
%GAMMA_CHAIN_INITIAL_STATE Build a positive two-patch initial condition.
%
% The chain variables are initialized from constant patch histories. This is
% not the only possible history, but it is stable and adequate for long
% transient simulations.

idx = gamma_chain_indices(shape);
z0 = zeros(idx.n, 1);
z0(idx.h1) = h1;
z0(idx.p1) = p1;
z0(idx.h2) = h2;
z0(idx.p2) = p2;
z0(idx.y1) = h1;
z0(idx.y2) = h2;
end

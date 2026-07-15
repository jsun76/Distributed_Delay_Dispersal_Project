function z0 = gamma_chain_initial_state(h1, p1, h2, p2, shape)
%GAMMA_CHAIN_INITIAL_STATE Initialize each delay chain with constant history.
idx = gamma_chain_indices(shape);
z0 = zeros(idx.n, 1);
z0([idx.h1 idx.p1 idx.h2 idx.p2]) = [h1 p1 h2 p2];
z0(idx.y1) = h1;
z0(idx.y2) = h2;
end

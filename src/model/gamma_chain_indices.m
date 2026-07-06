function idx = gamma_chain_indices(shape)
%GAMMA_CHAIN_INDICES State-vector indices for the two-patch chain model.

if shape < 1 || shape ~= round(shape)
    error('gamma_chain_indices:InvalidShape', ...
        'The gamma shape parameter p must be a positive integer.');
end

idx.h1 = 1;
idx.p1 = 2;
idx.h2 = 3;
idx.p2 = 4;
idx.y1 = 5:(4 + shape);
idx.y2 = (5 + shape):(4 + 2 * shape);
idx.n = 4 + 2 * shape;
end

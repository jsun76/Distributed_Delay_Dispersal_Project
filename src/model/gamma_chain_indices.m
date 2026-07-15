function idx = gamma_chain_indices(shape)
%GAMMA_CHAIN_INDICES State indices for the two-patch linear-chain model.
validateattributes(shape, {'numeric'}, {'scalar', 'integer', 'positive'});
idx.h1 = 1;
idx.p1 = 2;
idx.h2 = 3;
idx.p2 = 4;
idx.y1 = 4 + (1:shape);
idx.y2 = 4 + shape + (1:shape);
idx.n = 4 + 2 * shape;
end

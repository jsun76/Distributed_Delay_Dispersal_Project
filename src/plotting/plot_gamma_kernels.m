function fig = plot_gamma_kernels(shapeValues, meanDelay, filename)
%PLOT_GAMMA_KERNELS Plot gamma travel-time kernels for fixed mean delay.

if nargin < 1 || isempty(shapeValues)
    shapeValues = [1 2 5 15];
end
if nargin < 2 || isempty(meanDelay)
    meanDelay = 1;
end
if nargin < 3
    filename = '';
end

uMax = max(4 * meanDelay, 1);
u = linspace(0, uMax, 800);

fig = figure('Color', 'w');
hold on;
colors = lines(numel(shapeValues));

for k = 1:numel(shapeValues)
    shape = shapeValues(k);
    rate = shape / meanDelay;
    density = zeros(size(u));
    positive = u > 0;
    density(positive) = exp(shape * log(rate) + ...
        (shape - 1) * log(u(positive)) - rate * u(positive) - gammaln(shape));
    if shape == 1
        density(1) = rate;
    end

    plot(u, density, 'LineWidth', 2, 'Color', colors(k, :), ...
        'DisplayName', sprintf('p=%d, variance=%.3g', shape, meanDelay ^ 2 / shape));
end

xlabel('travel time');
ylabel('density');
title(sprintf('Gamma travel-time kernels, mean tau = %.3g', meanDelay));
legend('Location', 'northeast');
box on;
grid on;

save_project_figure(fig, filename);
end


function fig = plot_convergence_rates(results, filename)
%PLOT_CONVERGENCE_RATES Plot fitted convergence rate against variance.

if nargin < 2
    filename = '';
end

fig = figure('Color', 'w');
hold on;

tauRounded = round([results.tau] * 1e6) / 1e6;
tauValues = unique(tauRounded);
colors = lines(numel(tauValues));

for k = 1:numel(tauValues)
    mask = tauRounded == tauValues(k);
    variances = [results(mask).variance];
    rates = [results(mask).convergenceRate];
    [variances, order] = sort(variances);
    rates = rates(order);

    plot(variances, rates, 'o-', 'LineWidth', 1.5, ...
        'Color', colors(k, :), ...
        'DisplayName', sprintf('tau=%.3g', tauValues(k)));
end

xlabel('variance sigma^2');
ylabel('convergence rate');
title('Simulation-based convergence to phase locking');
legend('Location', 'best');
grid on;
box on;

save_project_figure(fig, filename);
end


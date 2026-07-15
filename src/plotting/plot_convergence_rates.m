function fig = plot_convergence_rates(results, filename)
%PLOT_CONVERGENCE_RATES Plot fitted convergence rate against variance.

if nargin < 2
    filename = '';
end

tauRounded = round([results.tau] * 1e6) / 1e6;
tauValues = unique(tauRounded);
if numel(tauValues) == 6
    panelTau = reshape(tauValues, 2, 3).';
    panelTitles = {'(a) anti-phase stable', ...
        '(b) bifurcations present', '(c) in-phase stable'};
else
    panelTau = tauValues(:).';
    panelTitles = {'Convergence-rate sweep'};
end

fig = figure('Color', 'w', 'Position', [100 100 1200 390]);
tiledlayout(1, size(panelTau, 1), 'TileSpacing', 'compact', 'Padding', 'compact');
colors = lines(max(2, size(panelTau, 2)));

for panel = 1:size(panelTau, 1)
    ax = nexttile;
    hold(ax, 'on');
    for curve = 1:size(panelTau, 2)
        tau = panelTau(panel, curve);
        mask = tauRounded == tau;
        variances = [results(mask).variance];
        rates = [results(mask).convergenceRate];
        [variances, order] = sort(variances);
        rates = rates(order);
        valid = isfinite(variances) & isfinite(rates);
        plot(ax, variances(valid), rates(valid), 'o-', 'LineWidth', 1.4, ...
            'MarkerSize', 3.5, 'Color', colors(curve, :), ...
            'DisplayName', sprintf('tau = %.2f', tau));
    end
    xlabel(ax, 'variance sigma^2');
    if panel == 1
        ylabel(ax, 'rate of convergence');
    end
    title(ax, panelTitles{min(panel, numel(panelTitles))});
    legend(ax, 'Location', 'best');
    grid(ax, 'on');
    box(ax, 'on');
end

sgtitle('Exponential convergence to the stable phase-locked orbit');

save_project_figure(fig, filename);
end


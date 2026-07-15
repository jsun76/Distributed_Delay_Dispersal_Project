function fig = plot_orbits(simulations, labels, filename)
%PLOT_ORBITS Plot prey time traces and h1-h2 projections.

if nargin < 2 || isempty(labels)
    labels = cell(numel(simulations), 1);
    for k = 1:numel(simulations)
        labels{k} = sprintf('p=%d, tau=%.3g', ...
            simulations{k}.shape, simulations{k}.tau);
    end
end
if nargin < 3
    filename = '';
end

n = numel(simulations);
fig = figure('Color', 'w', 'Position', [100 100 340 * n 620]);

for k = 1:n
    sim = simulations{k};
    tailStart = sim.t(1) + 0.65 * (sim.t(end) - sim.t(1));
    tailMask = sim.t >= tailStart;
    localTime = sim.t(tailMask) - sim.t(find(tailMask, 1, 'first'));

    subplot(2, n, k);
    plot(localTime, sim.h1(tailMask), 'LineWidth', 1.5);
    hold on;
    plot(localTime, sim.h2(tailMask), 'LineWidth', 1.5);
    xlabel('time');
    ylabel('prey abundance');
    title(labels{k});
    legend({'h1', 'h2'}, 'Location', 'best');
    grid on;
    box on;

    subplot(2, n, n + k);
    plot(sim.h1(tailMask), sim.h2(tailMask), 'k', 'LineWidth', 1.5);
    xlabel('h1');
    ylabel('h2');
    axis tight;
    grid on;
    box on;
end

save_project_figure(fig, filename);
end


function fig = plot_phase_regions(results, filename)
%PLOT_PHASE_REGIONS Scatter simulation classifications in tau-variance space.

if nargin < 2
    filename = '';
end

fig = figure('Color', 'w');
hold on;

classes = {'in-phase', 'anti-phase', 'out-of-phase', 'undetermined'};
colors = [0.92 0.65 0.10; ...
          0.00 0.45 0.74; ...
          0.05 0.05 0.05; ...
          0.55 0.55 0.55];
markers = {'o', 's', '^', 'x'};

labels = {results.classification};
tau = [results.tau];
variance = [results.variance];

for k = 1:numel(classes)
    mask = strcmp(labels, classes{k});
    if any(mask)
        scatter(tau(mask), variance(mask), 42, colors(k, :), markers{k}, ...
            'filled', 'DisplayName', classes{k});
    end
end

xlabel('mean delay tau');
ylabel('variance sigma^2');
title('Simulation-based phase-locking map');
legend('Location', 'best');
grid on;
box on;

save_project_figure(fig, filename);
end


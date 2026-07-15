function fig = plot_fig3_bifurcation_diagrams(results, filename)
%PLOT_FIG3_BIFURCATION_DIAGRAMS Plot Barbara Figure 3 style branches.

if nargin < 2
    filename = '';
end

fig = figure('Color', 'w', 'Position', [100 100 1150 780]);
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

panels = struct('shape', {2, 10, 15, 15}, ...
    'tauMax', {results.options.tauMax, results.options.tauMax, ...
    results.options.tauMax, results.options.zoomTauMax}, ...
    'title', {'(a) p = 2', '(b) p = 10', '(c) p = 15', '(d) p = 15, tau near 0'});

for panelIdx = 1:numel(panels)
    ax = nexttile;
    hold(ax, 'on');
    panel = panels(panelIdx);
    plot_shape_panel(ax, results, panel.shape, results.options.tauMin, ...
        panel.tauMax);
    title(ax, panel.title);
    xlabel(ax, 'mean delay tau');
    ylabel(ax, 'phase lag phi / pi');
    xlim(ax, [results.options.tauMin panel.tauMax]);
    ylim(ax, [-0.05 1.05]);
    yticks(ax, [0 0.5 1]);
    yticklabels(ax, {'0', '0.5', '1'});
    grid(ax, 'on');
    box(ax, 'on');
end

legendHandles = findobj(fig, '-regexp', 'DisplayName', '.+');
if ~isempty(legendHandles)
    legend(nexttile(1), 'Location', 'best');
end

sgtitle('MatCont bifurcation diagrams for phase-locked periodic orbits');
save_project_figure(fig, filename);
end

function plot_shape_panel(ax, results, shape, tauMin, tauMax)
branches = results.branches([results.branches.shape] == shape);
if isempty(branches)
    text(ax, 0.5, 0.5, 'No continuation data', 'Units', 'normalized', ...
        'HorizontalAlignment', 'center');
    return;
end

for k = 1:numel(branches)
    points = branches(k).points;
    if isempty(points)
        continue;
    end
    color = branch_color(branches(k).label);
    runIds = unique([points.runId], 'stable');
    for runIdx = 1:numel(runIds)
        runMask = [points.runId] == runIds(runIdx);
        runPoints = points(runMask);
        [~, order] = sort([runPoints.continuationIndex]);
        runPoints = runPoints(order);
        tau = [runPoints.tau];
        phase = [runPoints.phase] / pi;
        stable = [runPoints.stable];
        rangeMask = tau >= tauMin & tau <= tauMax & isfinite(phase);
        tau = tau(rangeMask);
        phase = phase(rangeMask);
        stable = stable(rangeMask);
        if isempty(tau)
            continue;
        end
        if runIdx == 1
            displayName = branches(k).label;
        else
            displayName = '';
        end
        plot_stability_segments(ax, tau, phase, stable, color, displayName);
    end
end

allSpecial = vertcat_special(branches.specialPoints);
if ~isempty(allSpecial)
    for k = 1:numel(allSpecial)
        if allSpecial(k).tau < tauMin || allSpecial(k).tau > tauMax
            continue;
        end
        y = allSpecial(k).phase / pi;
        if strcmp(allSpecial(k).type, 'BPC')
            plot(ax, allSpecial(k).tau, y, 'r*', 'MarkerSize', 8, ...
                'LineWidth', 1.2, 'DisplayName', 'BPC');
        elseif strcmp(allSpecial(k).type, 'LPC')
            plot(ax, allSpecial(k).tau, y, 'ro', 'MarkerSize', 5, ...
                'MarkerFaceColor', 'r', 'DisplayName', 'LPC');
        end
    end
end
end

function plot_stability_segments(ax, tau, phase, stable, color, displayName)
startIdx = 1;
usedName = false;
for idx = 2:(numel(tau) + 1)
    changed = idx > numel(tau) || ...
        ~same_stability(stable(idx), stable(startIdx));
    if changed
        segment = startIdx:(idx - 1);
        if ~isempty(segment)
            if isnan(stable(startIdx))
                style = ':';
            elseif stable(startIdx)
                style = '-';
            else
                style = '--';
            end
            if usedName || isempty(displayName)
                nameArg = {'HandleVisibility', 'off'};
            else
                nameArg = {'DisplayName', displayName};
                usedName = true;
            end
            plot(ax, tau(segment), phase(segment), style, 'Color', color, ...
                'LineWidth', 1.7, nameArg{:});
        end
        startIdx = idx;
    end
end
end

function tf = same_stability(left, right)
tf = (isnan(left) && isnan(right)) || ...
    (isfinite(left) && isfinite(right) && logical(left) == logical(right));
end

function color = branch_color(label)
switch lower(label)
    case 'in-phase'
        color = [0.92 0.65 0.10];
    case 'anti-phase'
        color = [0.00 0.45 0.74];
    otherwise
        color = [0.05 0.05 0.05];
end
end

function specials = vertcat_special(varargin)
specials = [];
for k = 1:nargin
    value = varargin{k};
    if ~isempty(value)
        specials = [specials; value(:)]; %#ok<AGROW>
    end
end
end


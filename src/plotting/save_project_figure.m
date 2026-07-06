function save_project_figure(fig, filename)
%SAVE_PROJECT_FIGURE Flush graphics and save a figure robustly.

if nargin < 1 || isempty(fig) || ~ishandle(fig)
    error('save_project_figure:InvalidFigure', ...
        'A valid figure handle is required.');
end
if nargin < 2
    filename = '';
end

figure(fig);
hide_axes_toolbars(fig);
drawnow;

if isempty(filename)
    return;
end

outputDir = fileparts(filename);
if ~isempty(outputDir) && ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

try
    exportgraphics(fig, filename, 'Resolution', 200);
catch
    saveas(fig, filename);
end

drawnow;
end

function hide_axes_toolbars(fig)
axesHandles = findall(fig, 'Type', 'axes');

for k = 1:numel(axesHandles)
    ax = axesHandles(k);
    try
        if isprop(ax, 'Toolbar') && ~isempty(ax.Toolbar)
            ax.Toolbar.Visible = 'off';
        end
    catch
        % Older MATLAB versions do not expose axes toolbar properties.
    end
end
end

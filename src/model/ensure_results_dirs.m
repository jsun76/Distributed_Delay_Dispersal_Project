function ensure_results_dirs(params)
%ENSURE_RESULTS_DIRS Create the output directories used by the workflows.
paths = {params.figureDir, params.rawDir, params.processedDir};
for k = 1:numel(paths)
    if ~exist(paths{k}, 'dir')
        mkdir(paths{k});
    end
end
end

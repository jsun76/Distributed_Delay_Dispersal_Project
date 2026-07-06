function ensure_results_dirs(params)
%ENSURE_RESULTS_DIRS Create output directories used by scripts.

dirs = {params.figureDir, params.rawDir, params.processedDir};

for k = 1:numel(dirs)
    if ~exist(dirs{k}, 'dir')
        mkdir(dirs{k});
    end
end
end

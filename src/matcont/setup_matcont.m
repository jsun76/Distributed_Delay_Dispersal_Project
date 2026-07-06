function cleanupObj = setup_matcont(projectRoot)
%SETUP_MATCONT Add the project-local MatCont installation for one workflow.

if nargin < 1 || isempty(projectRoot)
    projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

matcontRoot = fullfile(projectRoot, 'external', 'MatCont7p6');
if ~exist(fullfile(matcontRoot, 'init.m'), 'file')
    error('setup_matcont:MissingMatCont', ...
        ['MatCont was not found at %s. Download MatCont7p6 into ', ...
        'external/MatCont7p6 or update setup_matcont.m.'], matcontRoot);
end

oldPath = path;
oldDir = pwd;

cd(matcontRoot);
init();
cd(oldDir);

cleanupObj = onCleanup(@() restore_matcont_path(oldPath, oldDir));
end

function restore_matcont_path(oldPath, oldDir)
path(oldPath);
if exist(oldDir, 'dir')
    cd(oldDir);
end
end



function Dispersal(action)
%DISPERSAL Entry point for the Barbara reproduction workflows.
%
% Usage:
%   Dispersal                 show available commands
%   Dispersal('fig1')         gamma kernel figure
%   Dispersal('fig2')         representative orbit simulations
%   Dispersal('fig3')         MatCont bifurcation diagrams
%   Dispersal('fig4')         simulation-based phase-region map
%   Dispersal('fig5')         simulation-based convergence rates
%   Dispersal('level1')       run all reproduction scripts

projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(projectRoot, 'src')));

if nargin < 1 || isempty(action)
    action = 'help';
end

switch lower(action)
    case 'help'
        fprintf('Barbara reproduction commands:\n');
        fprintf('  Dispersal(''fig1'')    Gamma delay kernels\n');
        fprintf('  Dispersal(''fig2'')    Representative phase-locked orbits\n');
        fprintf('  Dispersal(''fig3'')    MatCont bifurcation diagrams\n');
        fprintf('  Dispersal(''fig4'')    Simulation-based phase-region map\n');
        fprintf('  Dispersal(''fig5'')    Simulation-based convergence rates\n');
        fprintf('  Dispersal(''level1'')  Run all reproduction scripts\n');
    case 'fig1'
        run(fullfile(projectRoot, 'scripts', 'reproduce_fig1_gamma.m'));
    case 'fig2'
        run(fullfile(projectRoot, 'scripts', 'reproduce_fig2_orbits.m'));
    case 'fig3'
        run(fullfile(projectRoot, 'scripts', 'reproduce_fig3_bifurcation_matcont.m'));
    case 'fig4'
        run(fullfile(projectRoot, 'scripts', 'reproduce_fig4_phase_regions.m'));
    case 'fig5'
        run(fullfile(projectRoot, 'scripts', 'reproduce_fig5_convergence.m'));
    case {'level1', 'all'}
        run(fullfile(projectRoot, 'scripts', 'reproduce_all_barbara_level1.m'));
    otherwise
        error('Dispersal:UnknownAction', 'Unknown action: %s', action);
end
end


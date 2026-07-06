<<<<<<< Updated upstream
close
clear
tic
%% INITIALIZING PARAMETERS %%

% Defining Parameters of the System
alpha = 0.35;
mu = 0.3;
eps = 0.1;
d = 0.001;
numpatches = 2;
p = 15;
tau = 1.5;

%Time span
tspan = [0,100];

zeroinitial = zeros(p - 1, numpatches);
y0 = [2; 0.001; 3; 1; 1; 1; zeroinitial(:)];

%% Running function %%

% Run ODE Solver and return time series
opts = odeset('RelTol',1e-8,'AbsTol',1e-10, 'NonNegative', 1:numel(y0));
[t, y] = ode45(@(t,z) DDDModel(t, z, alpha, mu, eps, d, numpatches, p, tau) , tspan, y0, opts);

ynotransient = y(t >= 50,:); 

%Check with Figure 2 of Barbara's paper
figure
hold on
plot(t, y(:,1),'b--');
plot(t, y(:,2), '-r');
xlabel('Time')
ylabel('h1')
hold off

figure
hold on
plot(ynotransient(:,1), ynotransient(:,2));
xlabel('h1')
ylabel('h2')
hold off
=======
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
>>>>>>> Stashed changes

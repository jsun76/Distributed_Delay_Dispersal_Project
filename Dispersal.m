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
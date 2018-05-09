%% Lab 2 - Rob�tica

%% main

clear
close all


% Simula��o ou realidade?
real = false;
% Mac ou windows?
mac = true;

% Declara��o de vari�veis
Nt = 500; % n� de elementos do vetor dos tempos
t_final = 15; % s
x_final = 15; % m
y_final = 10; % m
t = linspace(0, t_final, Nt)';
Nx = x_final * 100;
Ny = y_final * 100;
w = zeros(Nt, 1);
Np = 1000; % n� de pontos do vetor de trajet�ria

% Trajectory
[t_ref, x_ref, y_ref, theta_ref, w_ref] = trajectory_generator(Np);
trajectory = [t_ref, x_ref, y_ref, theta_ref, w_ref];


% Simulation or real robot?
if real
   RealRobot(mac,trajectory, t);
else
   Simulation(trajectory, t);
end
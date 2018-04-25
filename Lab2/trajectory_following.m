function [ w_next ] = trajectory_following(d, v,trajectory, w_actual, x, y, theta, t)
%trajectory_following: follows the trajectory
%   input: v -> constant, trajectory -> constant, d = 0?
% .        w_actual -> present angular velocity
%   output: w_next -> next angular velocity to meet trajectory


% x_ref and y_ref vector
x_ref_vector = trajectory(2,:,:);
y_ref_vector = trajectory(3,:,:);

% Finding x_ref, y_ref, theta_ref from trajectory
[~,i_x_ref] = min(abs(x_ref_vector - x));
x_ref = x_ref_vector(i_x_ref);
[~,i_y_ref] = min(abs(y_ref_vector - y));
y_ref = y_ref_vector(i_y_ref);
theta_ref = atan2((y_ref - y_ref_vector(i_y_ref-1))/(x_ref - x_ref_vector(i_y_ref-1)));

% Re-parametrizing the state space:
r = v / w_atual;
c_s = 1/r;
theta_til = theta_ref - theta;
dI = v * sin(theta_til);
I = norm([x, y] - [x_ref, y_ref]);

ds = v * cos(theta_til) / (1-c_s * I);
dtheta_til = w_actual;

% Values of the controllers
K2 = 20;
K3 = 11;
% (alternativa -> lqr)

u = -K2 * v * I - K3 * abs(v) * theta_til;
w_next  = 
end


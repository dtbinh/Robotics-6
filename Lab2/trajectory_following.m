function [w,v, x_ref, y_ref, x0, y0] = trajectory_following(trajectory, x, y, theta,x0_vec,y0_vec)
%trajectory_following: follows the trajectory
%   input: trajectory -> present trajectory (could be the corrected one)
%          x, y, theta -> robot coordinates
%          x0,y0 -> original trajectory coordinates to guide the robot
%          through the gains after correction
%   output: w_next -> next angular velocity to meet trajectory





% x_ref, y_ref vector and theta_ref vector
x_ref_vector = trajectory(:,2,:);
y_ref_vector = trajectory(:,3,:);
theta_ref_vector = trajectory(:,4,:);
w_ref_vector = trajectory(:,5,:);

% Finding x_ref, y_ref, theta_ref from trajectory
aux = sqrt((x_ref_vector-x).^2 + (y_ref_vector-y).^2);
[l,i_ref] = min(aux);
if i_ref == 1 % 1st step of the robot
   w=0;
   x_ref = 0; y_ref = 0; v = 3.5; x0 = 0; y0 = 0;
   return  
end
x_ref = x_ref_vector(i_ref);
y_ref = y_ref_vector(i_ref);
theta_ref = theta_ref_vector(i_ref);
w_ref = w_ref_vector(i_ref);
theta_ref_direction = [x_ref - x_ref_vector(i_ref-1), y_ref - y_ref_vector(i_ref-1) , 0];
l_direction = [x - x_ref , y - y_ref , 0];
x0 = x0_vec(i_ref);
y0 = y0_vec(i_ref);

[K2, K3, v_max, factor, w_open] = Type_of_trajectory (x0, y0);


% open-loop
if isnan(factor)
   w = w_open; v = v_max;
   return
end

% Relation between v and w
v =  abs(1 / ((w_ref/(2*pi))*factor));
if v > v_max
   v = v_max; 
end


% Re-parametrizing the state space and using the linearization
% r = v / w_ref; disp(r)
% c_s = 1/r; 
c_s = 0;
theta_til = theta_ref - theta;

% Signal of "l"
cross_prod = cross(theta_ref_direction, l_direction);
if cross_prod(3) < 0
   l = l * -1; 
end


u1 = - K2*v*l;
u2 =  K3*abs(v)*sin(theta_til);
u = u1+u2;


w = v*cos(theta_til)*c_s/(1-c_s*l) + u;
%w = w_ref + u;

%ang_speed_limit = 45; % degrees per second


% w = w_ref - gradSensors - K2*v*l;
ang_speed_limit = 45; % degrees per second 

if abs(w * 180 / pi) > ang_speed_limit
   warning('could not perform such high angular speed')
   w = ang_speed_limit * pi / 180 * sign(w);
end

end
function [t_query, x_ref_pp, y_ref_pp, theta_ref_pp, w_ref_pp] = trajectory_generator
%trajectory_generator: generates the reference trajectory
%   Detailed explanation goes here

% Measured points:
measured_points = [0,                                    0;... % [x,y]
                   1.8,                                  0;...
                   2.7,                              0.5+0;...
                   2.84,                              1.18;...
                   2.84,                                 2;...
                   2.84+0.15,                       1.18*2;...
                   2.84+0.15,                   2.36+0.495;... %pontos da sala
                   2.84+0.15,             2.36+0.495+1.668;...                   
                   2.99,             15.995+2.8550-1.206/2;...
                   2.99+15.747-(1.674+1.672)/2,    18.2470;...
                   17.064, 18.247-(15.767-(1.209+1.672)/2)];
                   %17.064-(15.743-(1.216+1.671)/2), 3.9205];   


t = linspace(0,10,size(measured_points,1));
x_measured = measured_points(:,1);
y_measured = measured_points(:,2);

% Interpolation
Nt = 126;
t_query = linspace(t(1), t(end), Nt)';
x_ref_pp = pchip(t, x_measured, t_query);
y_ref_pp = pchip(t, y_measured, t_query);

theta_ref_pp = zeros(Nt,1);
for i = 2:Nt
    theta_ref_pp(i) = atan2(y_ref_pp(i) - y_ref_pp(i-1),...
                         x_ref_pp(i) - x_ref_pp(i-1));                   
end
w_ref_pp = diff(theta_ref_pp)./diff(t_query);
w_ref_pp = [0; w_ref_pp];

% plotting the results

figure
plot(t_query, theta_ref_pp*180/pi)

figure(3)
hold on
plot(y_ref_pp, x_ref_pp)
set(gca,'Ydir','reverse')
plot(y_measured, x_measured, 'o')
set(gca,'Ydir','reverse')
title('Trajectory')
ylabel('x [m]')
xlabel('y [m]')

end


function trajectory = trajectory_generator
%trajectory_generator: generates the reference trajectory
%   Detailed explanation goes here

% Declaration of variables
Nt = 1000; % n� of trajectory points

% Measured points:
m = [1.671, 1.672, 1.672, 1.672, 1.206, 1.206, 1.209, 1.674, 1.705, ...
     1.203, 1.216, 1.672, 1.576, 1.668, 0.906, 0.972, 1.428, 2.10,...
     1.18,  0.74,  1.18,  0.15,  0.495, 0.20,  15.743,15.767,15.747,...
     15.71]; % m

a = m(28)+3.45-m(5)/2; b = m(26)-(m(7)+m(12))/2; c = 3.15; d = 3.45; %2.99 %2.36+0.495
e = 17.4585; f = 3.45 + (5.118 - 3.45)/2;

measured_points = [0,                                           0;... % [x,y]
                   1.8-0.8                                      0;...
                   2-0.3                                      0.2;...
                   2.7-0.4,                                   0.7;...
                   2.84-0.3,                                 1.18;...
                   c,                                       d-0.5;... %pontos da sala
                   c,                                     d+m(14);... 
                   c,                                       a-0.9;...
                   c+1,                                         a;...
                   16.39,                                       a;...
                   e,                                       17.95;...
                   e,                                  a-b+1+0.32;...
                   16,                                          f;...
                   4,                                           f;... % entra na sala
                   c,                                       d-0.5;...
                   2.84-0.3,                                 1.18;...
                   2.7-0.4,                                   0.7;...
                   2-0.3                                      0.2;...
                   1.8-0.8                                      0;...
                   0,                                           0];  

wid = 1e-6;
figure(3)
line([d+m(14), d+m(28)-m(5)],[c+m(1)/2, c+m(1)/2], 'Color', 'black',...
    'LineWidth', wid)
line([d, d+m(28)],[c-m(1)/2, c-m(1)/2], 'Color', 'black', 'LineWidth', wid)
line([d+m(28)-m(5), d+m(28)-m(5)],[c+m(1)/2, c+m(1)/2+m(27)-m(8)-m(4)],...
     'Color', 'black', 'LineWidth', wid)
line([d+m(28), d+m(28)],[c-m(1)/2, c-m(1)/2+m(27)],'Color', 'black',...
    'LineWidth', wid)
line([d+m(14), d+m(28)-m(5)],...
     [c+m(1)/2+m(27)-m(8)-m(4), c+m(1)/2+m(27)-m(8)-m(4)],'Color',...
     'black', 'LineWidth', wid)
line([d, d+m(28)], [c-m(1)/2+m(27), c-m(1)/2+m(27)],'Color', 'black'...
    , 'LineWidth', wid)
line([d+m(14), d+m(14)],[c+m(1)/2, c+m(1)/2+m(27)-m(8)-m(4)],...
    'Color', 'black', 'LineWidth', wid)
line([d, d],[c+m(1)/2, c-m(1)/2+m(27)],'Color', 'black', 'LineWidth', wid)

t = linspace(0,10,size(measured_points,1));
x_measured = measured_points(:,1);
y_measured = measured_points(:,2);

% Interpolation
t_query = linspace(t(1), t(end), Nt)';
x_ref_pp = pchip(t, x_measured, t_query);
y_ref_pp = pchip(t, y_measured, t_query);

theta_ref_pp = zeros(Nt,1);
for i = 2:Nt
    theta_ref_pp(i) = atan2(y_ref_pp(i) - y_ref_pp(i-1),...
                         x_ref_pp(i) - x_ref_pp(i-1));   
end
w_ref_pp = diff(wrapTo2Pi(theta_ref_pp))./diff(t_query);
w_ref_pp = [0; w_ref_pp];

aux_diff = diff(w_ref_pp);
[~,outlier] = max(aux_diff);
w_ref_pp(outlier+1) = 0;

% plotting the results

% figure
% plot(t_query, theta_ref_pp*180/pi)
% title('Evolution of \theta_ref')
% xlabel('Time(s)')
% ylabel('\theta (�)')

figure(3)
hold on
plot(y_ref_pp, x_ref_pp,'.')
set(gca,'Ydir','reverse')
plot(y_measured, x_measured, 'o')
%set(gca,'Ydir','reverse')
title('Trajectory')
ylabel('x [m]')
xlabel('y [m]')

trajectory = [t_query, x_ref_pp, y_ref_pp, theta_ref_pp, w_ref_pp];


end
function [ K2, K3, v] = Type_of_trajectory ( x, y )
%Type_of_trajectory: Breaks trajectory into curves and straight lines
%   Detailed explanation goes here

figure(3)
if y < 4.5 && x < 3.826 % curve zone
    v = 1.5;
    K2 = 2*v;
    K3 = 2*v;
    rectangle('Position',[0 0 4.5 3.826],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > 4.5 && y < 17.25 && x < 3.826 % straight line
    v = 3.5; % tested in 11/05 
    K2 = 0.8*v;
    K3 = 0.8*v;
    rectangle('Position',[4.5 0 17.25-4.5 3.826],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > 17.25 && y < 18.85 && x < 3.79 % curve
    v = 1;
    K2 = 8*v;
    K3 = 8*v;
    rectangle('Position',[17.25 0 18.85-17.25 3.79],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > 17.64 && y < 18.85 && x > 3.79 && x < 16.23 % straight line
    v = 2;
    K2 = 0.8*v;
    K3 = 0.8*v;
    rectangle('Position',[17.64 3.826  18.85-17.64 16.23-3.826],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > 17.64 && y < 18.85 && x > 16.23 && x < 17.9 % curve
    v = 1;
    K2 = 0.8*v;
    K3 = 0.8*v;
    rectangle('Position',[17.64 16.23 18.85-17.64 17.9-16.23],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > 4.523 && y < 17.64 && x > 16.23 && x < 17.9 % straight line
    v = 1;
    K2 = 0.01*v;
    K3 = 0.005*v;
    rectangle('Position',[4.523 16.23 (17.64-4.523) (17.9-16.23)],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
else
    v = 2;
    K2 = 0.01*v;
    K3 = 0.4*v;
    warning('Trajectory not feasible')
end

end
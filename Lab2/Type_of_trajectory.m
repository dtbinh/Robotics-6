function [ K2, K3, v, factor, w, sonar, j] = Type_of_trajectory (x, y)
%Type_of_trajectory: Breaks trajectory into curves and straight lines
%   Detailed explanation goes here

global lassie curve

figure(3)
factor = 7;
w = 0; sonar = 0;
a1 = 0.30*3; a2 = 0.30*4; a3 = 3.45; a4 = 5.5; a5 = 3.45+7.891-4; a6 = 16.5;
a7 = 17.66; a8 = 19.16;  a9 = 17.95-2; a10 = 19.5; a11 = 5.38+0.17;
a12 = 3.45;  a13 = 16.7;  a14 = 17.3;

b1 = 4 * 0.30; b2 = 3.986; b3 = 1.5; b4 = 3.99; b5 = 5.5; b6 = 15.57;
b7 = 16.39;     
b8 = 18.06;  b9 = 16.39; b10 = 16; b11 = b2 + 0.607;




if y < a1 && x < b1 && lassie == 0% straight line
    v = 3.5;
    w = 0; K2 = 0; K3 = 0; factor = NaN; j = 1;
    
    rectangle('Position',[0 0 a1 4*0.30],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
          
elseif y < a2 && x > b1 && x < b2 && lassie == 0 % curve zone
    v = 3.5;
    r = 0.41 * 4;
    w = v/r; K2 = 0; K3 = 0; factor = NaN; j = 2;
    rectangle('Position',[0 b1 a2 b2-a2],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a2 && y < a3 && x > b3 && x < b2 && lassie == 0 %straight line
    v = 3.5; r = 8;
    w = v/r;
    K2 = 0; K3 = 0; factor = NaN; j = 3;
    rectangle('Position',[a2 b3 a3-a2 b2-b3],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y >= a3 && y <= a4 && x <= b2 && lassie == 0 % straight line
    j = 4;
    v = 3;
    K2 = 1.5*v;
    K3 = 1*v; %1.5
    rectangle('Position',[a3 0 a4-a3 b2],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y >= a4 && y <= a5 && x <= b2 % sonar straight line
    sonar = 1;
    j = 5;
    v = 3;
    K2 = 1.5*v;
    K3 = 1*v; %1.5
%     K2 = 0; K3 = 0;
    rectangle('Position',[a4 0 a5-a4 b2],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a5 && y < a6 && x < b2 % big straight line
    j = 6;
    v = 3.5; % tested in 11/05 
    K2 = 0.6;
    K3 = 0.3;
    rectangle('Position',[a5 0 a6-a5 b2],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a6 && y < a7 && x < b2 % straight line
    j = 7;
    v = 2.5; % 2.5
    K2 = 1.5*v; %1
    K3 = 0.8*v;
    rectangle('Position',[a6 0 a7-a6 b2],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a7 && y < a8 && x < b4% curve 1
    j = 8;
    %v = 1.5161;
    v = 2;
    r = 0.8;
    w = -v/r; factor = NaN; K2 = 0; K3 = 0;
    rectangle('Position',[a7 0 a8-a7 b4],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a9 && y < a8 && x > b4 && x < b5 % straight line
    j = 9;
    v = 1.5;

    K2 = 1.5;
    K3 = 1;
%     w = 0; factor = NaN; K2 = 0; K3 = 0;

    rectangle('Position',[a9 b4  a8-a9 b5-b4],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a9 && y < a8 && x > b5 && x < b6 % big straight line
    sonar = 1;
    j = 10;
    v = 2.5;
    
%     K2 = 3;
%     K3 = 2;
    K2 = 0.7;
    K3 = 0.4;
%     K2 = 1.2*v;%4*v;
%     K3 = 0.8*v;%2*v;
%     w = 0; factor = NaN; K2 = 0; K3 = 0;
    rectangle('Position',[a9 b5  a8-a9 b6-b5],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a9 && y < a8 && x > b6 && x < b7 % straight line
    j = 11;
    v = 2.2; 
%     w = 0; factor = NaN; K2 = 0; K3 = 0;
    K2 = 0.8;%4*v;
    K3 = 1;%2*v;
    rectangle('Position',[a9 b6  a8-a9 b7-b6],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a9 && y < a10 && x > b7 && x < b8  % curve 2
    curve = 0;
    j = 12;
    v = 2;
    w = 0; factor = NaN; K2 = 0; K3 = 0;
%     r = 0.8;
%     w = -v/r; factor = NaN; K2 = 0; K3 = 0;
    rectangle('Position',[a9 b7 a10-a9 b8-b7],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a13 && y < a14 && x > b9 && x < b8 % straight line
    j = 13;
    v = 1.5;
    K2 = 1.5;
    K3 = 1;
    rectangle('Position',[a14 b9 (a14-a13) (b8-b9)],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a11 && y < a9 && x > b9 && x < b8 % straight line
    j = 14;
    v = 2.5;
    K2 = 0.7;
    K3 = 0.4;
    rectangle('Position',[a11 b9 (a9-a11) (b8-b9)],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a12 && y < a11 && x > b10 && x < b8 % curve 3
    j = 15;
    v = 2.3;
    r = 1.3;
    w = -v/r; factor = NaN; K2 = 0; K3 = 0;
    rectangle('Position',[a12 b10 (a11-a12) (b8-b10)],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a12 && y < a11 && x <= b10 && x > b11 % last line
    lassie = 1;
    j = 16;
    v = 3.5;
    K2 = 0.8*v;
    K3 = 0.4*v;
    rectangle('Position',[a12 b11 (a11-a12) (b10-b11)],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y < a1 && x < b1 && lassie == 1 % straight line
    v = 3.5;
    w = 0; K2 = 0; K3 = 0; factor = NaN; j = 1;
    
    rectangle('Position',[0 0 a1 4*0.30],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
          
elseif y < a2 && x > b1 && x < b2 && lassie == 1 % curve zone
    v = 3.5;
    r = 0.41 * 4;
    w = -v/r; K2 = 0; K3 = 0; factor = NaN; j = 2;
    rectangle('Position',[0 b1 a2 b2-a2],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y > a2 && y < a3 && x > b3 && x < b2 && lassie == 1 %straight line
    v = 3.5; w = 0;
    K2 = 0; K3 = 0; factor = NaN; j = 3;
    rectangle('Position',[a2 b3 a3-a2 b2-b3],'LineStyle','--',...
        'EdgeColor', [0.8, 0.8, 0.8])
elseif y >= a3 && y <= a4 && x <= b11 && lassie == 1 % straight line
    v = 2.5; r = 1.25;
    w = v/r;
    K2 = 0; K3 = 0; factor = NaN; j = 4;
    rectangle('Position',[a3 0 a4-a3 b11],'LineStyle','--',...
              'EdgeColor', [0.8, 0.8, 0.8])
elseif x < 0
    pioneer_set_controls(Sp,0,0);
    msgbox('V I C T O R Y')
    exit
else
    v = 1;
    j = 100;
    K2 = 8*v;
    K3 = 4*v;
    disp(x), disp(y)
    warning('Trajectory not feasible')
end

end
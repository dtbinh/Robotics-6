function [w_vec]=RealRobot(trajectory,Sp)
%RealRobot: Moves the robot in the lab
%   Detailed explanation goes here

T = 1; % period of the timer
v_vec = [];
w_vec = [];
x_vec = [];
y_vec = [];
theta_vec = [];
aux1 =[];
  
vec = pioneer_read_odometry;
x = vec(1);
y = vec(2);
theta = vec(3);
  
x = x * 0.001; % m
x_vec = [x_vec; x];
y = y * 0.001; % m
y_vec = [y_vec; y];
theta = theta * 0.1 * pi / 180; % rad
theta_vec = [theta_vec; theta];
[w,v, x_ref, y_ref] = trajectory_following(trajectory, x, y, theta);
w_vec = [w_vec; w]; 

%t = timer('Period', T, 'ExecutionMode', 'fixedRate');
%t.TimerFcn=@(v,w,Sp)pioneer_set_controls (Sp, round(v*100), round(wrapTo2Pi(w)*180/pi));
%start(t)

% t.StartFcn = {@my_callback_fcn, 'Starting moving the robot'};
pioneer_set_controls (Sp, round(v*100), round(w*180/pi)); % confirmar unidades!
j = 0;
while (1) 
  j = j+1;
  
  vec = pioneer_read_odometry;
  x = vec(1);
  y = vec(2);
  theta = vec(3);
  x = x * 0.001; % m
  x_vec = [x_vec; x];
  y = y * 0.001; % m
  y_vec = [y_vec; y];
  theta = theta * 0.1 * pi / 180; % rad
  figure(4)
  subplot(3,1,1), plot(j,x, 'x'), title('x'), hold on
  subplot(3,1,2), plot(j,y, 'x'), title('y'), hold on
  subplot(3,1,3), plot(j,theta, 'x'), title('\theta'), hold on
  figure(3), plot(y,x, 'x','Color',[1, 0.7, 0])
  plot(y_ref, x_ref,'x','Color', 'g') 
  theta_vec = [theta_vec; theta];
  [w,v, x_ref, y_ref] = trajectory_following(trajectory, x, y, theta);
 
  w_vec = [w_vec; w];
  v_vec = [v_vec; v];
  
  aux = pioneer_read_sonars;
%   if (aux(1)<500||aux(8)<500||aux(4)<500||aux(5)<500)
%       %stop(t)
%       break
%   end
  pause(0.01)
  pioneer_set_controls (Sp, round(v*100), round(w*180/pi*0.1));
  
  %aux1 = [aux1; aux];
end

pioneer_set_controls(Sp,0,0);

end


% function my_callback_fcn(obj, event, text_arg)
% 
% txt1 = ' event occurred at ';
% txt2 = text_arg;
% 
% event_type = event.Type;
% event_time = datestr(event.Data.time);
% 
% msg = [event_type txt1 event_time];
% disp(msg)
% disp(txt2)
% end
% 
% function [] = updateRobot(v,w,Sp)
%     pioneer_set_controls (Sp, round(v*100), round(wrapTo2Pi(w)*180/pi)); % confirmar unidades!
% end



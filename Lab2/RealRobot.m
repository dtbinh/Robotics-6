function RealRobot(trajectory,Sp)
%RealRobot: Moves the robot in the lab
%   Detailed explanation goes here

global lassie curve
curve = 1;
lassie = 0;
bread = 1;
% wOffset = -(0.08/20/5.08+0.075/20/5.062)*10; % pioneer 4: desvia direita
% wOffset = -2*(0.07/20/5.005+0.0057/20/5.032)/2; % pioneer 7: desvia esquerda
wOffset = 0.092/15/5.271; % pioneer 4 corre��o
FACTOR_PIONEER4 = 1;

T_mov = 0.1; % period of the moving timer
T_sens = 0.03; % period of the sensors timer
T_odom = 0;

% robot data
N = 1500;
v_vec = zeros(N,1);
w_vec = zeros(N,1);
x_vec = zeros(N,1);
x_noodo = zeros(N,1);
y_vec = zeros(N,1);
y_noodo = zeros(N,1);
theta_vec = zeros(N,1);
sensors = zeros(N,8);
gradSensors= zeros(N,8);



% Correction of trajectory
theta_real = zeros(N,1);
correctSensX = 0;
correctSensY = 0;
correctSensTheta = 0;
corr_flag = 0;
stop_corr = 0;
corr2 = 1;
corr_y = 1;
x0_vec = trajectory(:,2);
y0_vec = trajectory(:,3);

% initial reading
vec = pioneer_read_odometry;
x = vec(1);
y = vec(2);
theta = vec(3);

x_vec(1) = x*0.001;
x_noodo(1) = x*0.001;
y_vec(1) = y*0.001;
y_noodo(1) = y*0.001;
theta = theta * 0.1 * pi / 180; % rad
theta_vec(1) = theta;
[w,v, x_ref, y_ref, x0, y0] = trajectory_following(trajectory, x, y, theta, x0_vec, y0_vec);
w_vec(1) = w;
v_vec(1) = v;

% sendMoveTimer = timer('Period', T_mov, 'ExecutionMode', 'fixedRate');
% sendMoveTimer.StartFcn = {@starting,"Starting the motion of the robot..."};
% sendMoveTimer.TimerFcn = @updateRobotFlag;
% readSensorTimer = timer('Period', T_sens, 'ExecutionMode', 'fixedRate');
% readSensorTimer.StartFcn = {@starting,"Staring reading the sonars"};
% readSensorTimer.TimerFcn = @updateSensorFlag;
% start(sendMoveTimer);
% start(readSensorTimer);

% initial move
pioneer_set_controls (Sp, round(v*100), round(w*180/pi*0.1));
pause(T_mov);
j = 1;
while (j<N)
    j = j+1;
    
    vec = pioneer_read_odometry;
    sonar = pioneer_read_sonars/1000; % puts everything in meters
    
    sensors(j,:) = sonar(1:8);
    gradSensors(j,:) = sensors(j,:)-sensors(j-1,:);
    
    
    % stops in front of obstacle
    while (sonar(4) < 0.2 || sonar(5) < 0.2)
        pioneer_set_controls (Sp, 0, 0);
        pause(T_mov)
        sonar = pioneer_read_sonars/1000; % puts everything in meters
    end
    
    %fprintf('(x,y)=(%d,%d),   grad sensor=%d\n',vec(1),vec(2),gradSensors(j,8));
    
    % Correct position using odometry
    %     if (rem(j,250)~=0)
    if (rem(j,10000)~=0)
        T_odom = j*T_mov;
    else
        T_odom = 0;
    end
    
    correctOdoX = -sin(theta_vec(j-1))*sin(wOffset*T_odom)*v_vec(j-1)*T_mov;
    correctOdoY = cos(theta_vec(j-1))*sin(wOffset*T_odom)*v_vec(j-1)*T_mov;
    correctOdoTheta = wOffset*T_odom;
    %fprintf('OdoX:%f, OdoY:%f, OdoThe:%f\n',correctOdoX,correctOdoY,correctOdoTheta);
    
    x_noodo(j) = vec(1)*0.001;
    x = vec(1)*0.001 + correctSensX + correctOdoX;
    y_noodo(j) = vec(2)*0.001;
    y = vec(2)*0.001 + correctSensY + correctOdoY;
    if vec(3) > 3600
        vec(3) = 360/4094 * vec(3) * 10;
    end
    theta = wrapToPi(vec(3)*0.1*pi/180) + correctOdoTheta - correctSensTheta;
    
    %fprintf('VecX:%f, X:%f, VecY:%f, Y:%f\n',vec(1)*0.001,x,vec(2)*0.001,y);
        figure(4)
        subplot(3,1,1), plot(j,x, 'x'), title('x'), hold on
        subplot(3,1,2), plot(j,y, 'x'), title('y'), hold on
        subplot(3,1,3), plot(j,theta, 'x'), title('\theta'), hold on
    
    
    % sonars
    [~,~,~,~,~,sonar_signal,jo] = Type_of_trajectory (x0,y0);
    type = '.';
    if jo == 11
        corr_y = 1; 
    end
%     if sonar_signal
%         
%         % corrects odometry from sonars
%         if corr_flag == 1 && stop_corr == 0
%             % remove all zeros from vector
%             
%             theta_real(theta_real == 0) = [];
%             
%             theta_correction = mean(theta_real);
%             disp(theta_correction*180/pi);
%             %             correctSensTheta = theta_correction - pi/2;
%             correctSensTheta=0;
%             %
%             figure(6), plot(theta_real*180/pi), title('angulo sonares')
%             % reallocates vector to get it ready for another correction
%             theta_real = zeros(N,1);
%             stop_corr = 1;
%             
%             psi = -correctSensTheta;
%             newTraj = [cos(psi)*trajectory(:,2)-sin(psi)*trajectory(:,3),...
%                 sin(psi)*trajectory(:,2)+cos(psi)*trajectory(:,3),...
%                 trajectory(:,4) + psi];
%             trajectory(:,2:4)=newTraj;
%             disp('ol�')
%             figure(3), hold on;
%             plot(trajectory(:,3),trajectory(:,2),'.')
%         end
%         
%         % sonar correction
%         [theta_real(j),corr_flag, type] = ...
%             sonar_correction(x,y,theta,x_ref,y_ref,jo,gradSensors,j,T_mov, sensors(j,:));
%         
%     end
    
    
    %     % corrects y in the 2nd corridor
    %     if gradSensors(j,8)>=0.078 && x > 15.57 && x < 16
    %         beep
    %         correctSensX = -(15.7590 - x);
    %         disp(correctSensX)
    %     end
    
    
    
    
    % emergency turn 2
    %     threshold = 0.67;
    %     if sonar (4) < threshold && j == 11
    %         correctSensX = -(18.06-sonar(4) - x);
    %         disp(correctSensX)
    %     end
    
    %     threshold = 1;
    %     if gradSensors(j,8) > threshold && j == 7
    %         y_real = 17.66;
    %         correctSensY = -(y_real - y);
    %         disp(correctSensY)
    %     end
    
    % corrects x from corridor edge
%     threshold = 1;
%     if abs(gradSensors(j,8)) > threshold && (jo == 11 || jo == 12) && corr2 == 1
%         x_real = 16.39;
%         correctSensX = (x_real - x);
%         disp(correctSensX)
%         corr2 = 0;
%     end
    
    figure(5)
    subplot(3,1,1), plot(j,sonar(1),type,'Color','g'), hold on
    subplot(3,1,2), plot(j,sonar(8),type,'Color','b'), hold on
    subplot(3,1,3), plot(j,gradSensors(j,8),type,'Color','r'), hold on
    
    %plots odometry evolution in time
        figure(4)
        subplot(3,1,1), plot(j,x, 'x'), title('x'), hold on
        subplot(3,1,2), plot(j,y, 'x'), title('y'), hold on
        subplot(3,1,3), plot(j,theta, 'x'), title('\theta'), hold on
        
        figure(10)
        plot(j,w, 'x'), title('\omega'), hold on

    
    
    % plots trajectory evolution in time
    figure(3)
    % trajetoria do robot
    %plot(y,x, 'x','Color',[1, 0.7, 0])
    %plot(y_ref, x_ref,'x','Color', 'g')
    
    % end of sonar part
    if bread && sonar(1) < 1.5 && jo > 4
        psi = abs(atan2(gradSensors(j,1), T_mov));
        if gradSensors(j,1) > 0
            psi = psi * -1;
        end
        if jo == 5 || jo == 6 || jo == 7 % 1st corridor
            x_real = 2.314 + sonar(1);
            %             correctSensX = (x_real - x)
            x = x_real;
            theta = psi + pi/2;

        elseif jo == 9 || jo == 10 || jo == 11 % 2nd corridor

            y_real = 19.06 - sonar(1);

            %correctSensY = y_real - y;
            y = y_real;
            theta = psi;
            %             w = w - 10*pi/180;
        elseif jo == 13 || jo == 14 % 3rd corridor
            x = 18.06 - sonar(1);
            theta = psi - pi/2;
        elseif  jo == 16            % 4th corridor
            y = sonar(1) + 3.45;
            theta = psi + pi; %cuidado com discontinuidade
        end
        
        
    elseif bread && sonar(1) > 1.5 && jo > 4
        if jo == 5 || jo == 6 || jo == 7 % 1st corridor
            x = x_vec(j-1);
        elseif jo == 9 || jo == 10 || jo == 11 % 2nd corridor
            y = y_vec(j-1);
        elseif jo == 13 || jo == 14 % 3rd corridor
            x = x_vec(j-1);
        elseif  jo == 16            % 4th corridor
            y = y_vec(j-1);
        end
        theta = theta_vec(j-1);
    end
    
    % curve process
    if bread && gradSensors(j,8) > 0.8 && jo == 7 && corr_y == 1
        corr_y = 0;
        y_real = 17.474;
        correctSensY = y_real - y
        y = y_real;
        
        v = 1;
        w = 0;
        %r = 0.8;
        %w = -v/r;
        
        while (sonar(4) > 0.65 && sonar(5) > 0.65)
            pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*0.1*FACTOR_PIONEER4));
            pause(T_mov)
            sonar = pioneer_read_sonars/1000; % puts everything in meters
            sonar = sonar(1:8)
        end
        pause(T_mov+1)
        pioneer_set_controls(Sp, round(pi/2*0.3*100), round(-pi/2*180/pi*1))
        pause(1) % novo 1-0.05
        v = 2.5;
        pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*0.1*FACTOR_PIONEER4));
        pause(5)
        % correction after performing the curve
        sonar = pioneer_read_sonars/1000; % puts everything in meters
        sonar = sonar(1:8);
        if sonar(8) < sonar(1)
            y = 17.474 + sonar(8); % cuidado
        else
            y = 19.06 - sonar(1);
        end
        vec = pioneer_read_odometry;
        x = vec(1)*0.001 + correctSensX + correctOdoX;
        if vec(3) > 3600
            vec(3) = 360/4094 * vec(3) * 10;
        end
        theta = wrapToPi(vec(3)*0.1*pi/180) + correctOdoTheta - correctSensTheta;
    elseif bread && gradSensors(j,8) > 0.8 && (jo == 11 || jo == 12) && corr_y == 1
        x_real = 16.39;
        correctSensX = x_real - x
        x = x_real;
        corr_y = 0;
        
        v = 1;
        w = 0;
        %r = 0.8;
        %w = -v/r;
        
        while (sonar(4) > 0.65 && sonar(5) > 0.65)
            pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*0.1*FACTOR_PIONEER4));
            pause(T_mov)
            sonar = pioneer_read_sonars/1000; % puts everything in meters
            sonar = sonar(1:8);
        end
        pause(T_mov+1)
        pioneer_set_controls(Sp, round(pi/2*0.3*100), round(-pi/2*180/pi*1))
        pause(1)
        v = 2.5;
        pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*0.1*FACTOR_PIONEER4));
        pause(5)
        % correction after performing the curve
        sonar = pioneer_read_sonars/1000; % puts everything in meters
        sonar = sonar(1:8);
        x = 18.06 - sonar(1);
        vec = pioneer_read_odometry;
        y = vec(1)*0.001 + correctSensY + correctOdoY;
        if vec(3) > 3600
            vec(3) = 360/4094 * vec(3) * 10;
        end
        theta = wrapToPi(vec(3)*0.1*pi/180) + correctOdoTheta - correctSensTheta;
    end
    
    x_vec(j) = x;
    y_vec(j) = y;
    
    figure(3), plot(y,x, 'x','Color',[1, 0.7, 0])
    plot(y_ref, x_ref,'x','Color', 'g')
    theta_vec(j) = theta;
    
    
    
    
    [w,v, x_ref, y_ref, x0, y0] = trajectory_following(trajectory, x, y, theta, x0_vec,y0_vec);
    
    w_vec(j) = w;
    v_vec(j) = v;
    
%     % anti-crash
%     if sonar(1) < 0.205
%        w = w - pi/6;
%        pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*FACTOR_PIONEER4));
%        pause(1)
%        w = w + pi/6;
%        pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*FACTOR_PIONEER4));
%        pause(1)
%     elseif sonar(8) < 0.205
%        w = w + pi/6;
%        pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*FACTOR_PIONEER4));
%        pause(1)
%        w = w - pi/6;
%        pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*FACTOR_PIONEER4));
%        pause(1)
%     end
%     
    pioneer_set_controls (Sp, round(v*100), round((w)*180/pi*0.1*FACTOR_PIONEER4));
    pause(T_mov)
    
end

pioneer_set_controls(Sp,0,0);
figure, hold on;
plot(x_noodo,y_noodo,'x');
plot(x_vec,y_vec,'x');
save('sensors.mat', 'gradSensors', 'sensors');
save('simulation.mat','x_vec','y_vec');
legend('sem corre�ao','com corre��o');


[y, Fs] = audioread('sm.mp3');
sound(y,Fs);
end



% function starting(obj, event, message)
%
% txt1 = ' event occurred at ';
% event_type = event.Type;
% event_time = datestr(event.Data.time);
%
% msg = [event_type txt1 event_time];
% disp(msg)
% disp(message)
%
% end
%
% function updateRobotFlag(Obj,event)
%
% global flagUpdateRobot;
% flagUpdateRobot = 1;
%
% end
%
% function updateSensorFlag(Obj,event)
%
% global flagSensorRobot;
% flagSensorRobot = 1;
%
% end
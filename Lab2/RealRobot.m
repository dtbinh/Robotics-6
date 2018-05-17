function RealRobot(trajectory,Sp)
%RealRobot: Moves the robot in the lab
%   Detailed explanation goes here

% global flagUpdateRobot;
% flagUpdateRobot = 0;

% wOffset = (0.08/20/5.08+0.075/20/5.062)/2; % pioneer 4
wOffset = (0.07/20/5.005+0.0057/20/5.032)/2; % pioneer 7: desvia esquerda

T_mov = 0.08; % period of the moving timer
T_sens = 0.03; % period of the sensors timer

N = 10000;
v_vec = zeros(N,1);
w_vec = zeros(N,1);
x_vec = zeros(N,1);
y_vec = zeros(N,1);
theta_vec = zeros(N,1);
sensors = zeros(N,8);
gradSensors= zeros(N,8);
correctSensX = 0;
correctSensY = 0;

vec = pioneer_read_odometry;
x = vec(1);
y = vec(2);
theta = vec(3);

x = x * 0.001; % m
x_vec(1) = x;
y = y * 0.001; % m
y_vec(1) = y;
theta = theta * 0.1 * pi / 180; % rad
theta_vec(1) = theta;
[w,v, x_ref, y_ref] = trajectory_following(trajectory, x, y, theta);
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


pioneer_set_controls (Sp, round(v*100), round(w*180/pi*0.1)); % confirmar unidades!
j = 1; w_sonar = 0;
while (j<N)
    j = j+1;
    
    vec = pioneer_read_odometry;
    aux = pioneer_read_sonars;
    % colocar ciclo while para por o robot a parar quando houver um obstaculo
    sensors(j,:) = aux(1:8);
    gradSensors(j,:) = sensors(j,:)-sensors(j-1,:);
        
    %fprintf('(x,y)=(%d,%d),   grad sensor=%d\n',vec(1),vec(2),gradSensors(j,8));
    if (vec(2)>2.7 && vec(1)<3.826) && gradSensors(end,8)>=2400
        beep;
        correctSensY = 3.41 - vec(2);
    end
    w_correction = wOffset;
    
    [~,~,~,~,~,sonar_signal] = Type_of_trajectory ( x, y );
    sonar = pioneer_read_sonars;
    type = '.';
    if sonar_signal
        % sonar correction
        [w_inc, sonar] = sonar_correction;
        figure(5)
%         subplot(2,1,1), plot(j,sonar(1),'x','Color','g'), hold on
%         subplot(2,1,2), plot(j,sonar(8),'x','Color','b'), hold on
        type = 'x';
        w_sonar = w_sonar + w_inc;
        disp(w_sonar);
        w_correction = wOffset + w_sonar;
    end
    figure(5)
    subplot(3,1,1), plot(j,sonar(1),type,'Color','g'), hold on
    subplot(3,1,2), plot(j,sonar(8),type,'Color','b'), hold on
    subplot(3,1,3), plot(j,w_correction,type,'Color','r'), hold on


    
    correctOdoX = -sin(theta_vec(j-1))*sin(w_correction*T_mov)*v_vec(j-1)*T_mov;
    correctOdoY = cos(theta_vec(j-1))*sin(w_correction*T_mov)*v_vec(j-1)*T_mov;
    correctOdoTheta = w_correction*T_mov;
    %fprintf('OdoX:%f, OdoY:%f, OdoTheta:%f',correctOdoX,correctOdoY,correctOdoTheta);    
    

    x = vec(1) + correctSensX + correctOdoX;
    y = vec(2) + correctSensY + correctOdoY;
    theta = vec(3) + correctOdoTheta;
    x = x * 0.001; % m
    x_vec(j) = x;
    y = y * 0.001; % m
    y_vec(j) = y;
    theta = theta * 0.1 * pi / 180; % rad
    
    % faz plot da odometria ao longo do tempo
%     figure(4)
%     subplot(3,1,1), plot(j,x, 'x'), title('x'), hold on
%     subplot(3,1,2), plot(j,y, 'x'), title('y'), hold on
%     subplot(3,1,3), plot(j,theta, 'x'), title('\theta'), hold on

    % faz plot da trajetoria ao longo do tempo
    plot_trajectory(x,y,sonar)
    %plot(y_ref, x_ref,'x','Color', 'g')
    
    % faz plot da leitura dos sonares ao longo da trajetoria
    
    
    theta_vec(j) = theta;
    
    [w,v, x_ref, y_ref] = trajectory_following(trajectory, x, y, theta);
    
    w_vec(j) = w+w_correction;
    v_vec(j) = v;
    
    pioneer_set_controls (Sp, round(v*100), round((w+w_correction)*180/pi*0.1));
    pause(T_mov)
    
%     if flagUpdateRobot==1
%         disp([v w])
%         pioneer_set_controls (Sp, round(v*100), round(w*180/pi*0.1));
%         flagUpdateRobot = 0;
%     end
    
%     if flagUpdateSensor==1
%         aux = pioneer_read_sonars;
%         % colocar ciclo while para por o robot a parar quando houver um ostaculo
%         sensors = [sensors; aux];
%         if length(sensors) == 1
%             gradSensors = [gradSensors;zeros(1,8)];
%         else
%             gradSensors = [gradSensors;sensors(end)-sensors(end-1)];
%         end
%     end
    %aux1 = [aux1; aux];
end

pioneer_set_controls(Sp,0,0);
save('sensors.mat', 'gradSensors', 'sensors');

end


function starting(obj, event, message)

txt1 = ' event occurred at ';
event_type = event.Type;
event_time = datestr(event.Data.time);

msg = [event_type txt1 event_time];
disp(msg)
disp(message)

end

function updateRobotFlag(Obj,event)

global flagUpdateRobot;
flagUpdateRobot = 1;

end

function updateSensorFlag(Obj,event)

global flagSensorRobot;
flagSensorRobot = 1;

end
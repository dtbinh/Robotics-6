function theta = InverseKinematics(alpha,beta,gama,x,y,z)

ZERO = 1e-8;
L = [25e-3 99e-3 120e-3 21e-3 0 0 120e-3 20e-3];
% Getting the convention matrix
firstLine = [cos(alpha)*cos(gama) - sin(alpha)*cos(beta)*sin(gama) ...
    -cos(alpha)*sin(gama) - sin(alpha)*cos(beta)*cos(gama) ...
    sin(alpha)*sin(beta) x];
secondLine = [sin(alpha)*cos(gama) + cos(alpha)*cos(beta)*sin(gama) ...
    -sin(alpha)*sin(gama) + cos(alpha)*cos(beta)*cos(gama) ...
    -cos(alpha)*sin(beta) y];
thirdLine = [sin(beta)*sin(gama) sin(beta)*cos(gama) cos(beta) z];
fourthLine = [0 0 0 1];
conventionMatrixT06 = [firstLine; secondLine; thirdLine; fourthLine];

% Getting theta1
if abs(conventionMatrixT06(2,1)) < ZERO && abs(conventionMatrixT06(1,1)) < ZERO
  theta = -pi/2 + atan2(conventionMatrixT06(2,2),conventionMatrixT06(1,2));
  theta1 = [theta; theta + pi];
else 
  theta = pi/2 + atan2(conventionMatrixT06(2,1),conventionMatrixT06(1,1));
  theta1 = [theta; theta + pi];
end

% Getting the position of joint 5 in the world frame
posJoint5toFrame6 = [0;0;-20e-3];
transformation = conventionMatrixT06*[posJoint5toFrame6;1];
posJoint5toFrame0 = transformation(1:3);

theta3 = [];
theta2 = [];
% Getting theta3 and theta2
for i = 1:length(theta1)
  height5NotTotal = posJoint5toFrame0(3) - 99e-3;
  module = sqrt(posJoint5toFrame0(1)^2 + posJoint5toFrame0(2)^2);
  if i == 1
    distance5NotTotal = module - 25e-3;    
    if angdiff(theta1(i),pi + atan2(posJoint5toFrame0(2),posJoint5toFrame0(1))) ~= 0
      distance5NotTotal = -module - 25e-3;  
    end
  else
    distance5NotTotal = -module + 25e-3;
    if angdiff(theta1(i),pi + atan2(posJoint5toFrame0(2),posJoint5toFrame0(1))) ~= 0
      distance5NotTotal = module + 25e-3;  
    end
  end 
%   if i == 1
%      distance5NotTotal = sqrt(posJoint5toFrame0(1)^2 + posJoint5toFrame0(2)^2) - 25e-3;
%   else
%      distance5NotTotal = sqrt(posJoint5toFrame0(1)^2 + posJoint5toFrame0(2)^2) + 25e-3; 
%   end
  %distance5NotTotal = 0; test when there is no triangule
  a1 = 120e-3;
  a2 = sqrt((120e-3)^2 + (21e-3)^2);
  %height5NotTotal = a1 + a2; test when there is no triangule
  arg = (-height5NotTotal^2 - distance5NotTotal^2 + a1^2 + a2^2)/(2*a1*a2);
  if abs(arg) > 1 % if cosine gives a value bigger than +-1
    warning('The point is not in the range of the arm in this possible configuration')
    continue
  end
  psi = atan(120e-3/21e-3);
  if i == 1
    theta3aux1 = pi - psi - acos(arg);
    theta3aux2 = -pi + acos(arg) - psi;
  else
    theta3aux1 = -(pi - acos(arg) + psi);
    theta3aux2 = -(-pi + acos(arg) + psi); % - because the frame change 
  end
  theta3 = [theta3; theta3aux1; theta3aux2];
 
  centralAngle = atan2(height5NotTotal,distance5NotTotal);
  arg = (height5NotTotal^2 + distance5NotTotal^2 + a1^2 - a2^2)/...
      (2*a1*sqrt(height5NotTotal^2 + distance5NotTotal^2));
  fi = acos(arg);
  if i == 1
    theta2st = pi/2 - centralAngle - fi;
    theta2nd = pi/2 - centralAngle + fi;
  else
    theta2st = -(pi/2 - centralAngle - fi); 
    theta2nd = -(pi/2 - centralAngle + fi); % - because the frame change
  end
  theta2 = [theta2; theta2st ; theta2nd];
end

theta = [theta1(1) theta2(1) theta3(1); theta1(1) theta2(2) theta3(2);
    theta1(2) theta2(3) theta3(3); theta1(2) theta2(4) theta3(4)];
%distance for theta 3: 120mm

% Getting theta4,theta5 and theta6
orientThetastSol = [];
orientThetandSol = [];
for i =1:4 %4 solutions from the previous joints
  T01 = [cos(theta(i,1)) -sin(theta(i,1)) 0 0;sin(theta(i,1)) cos(theta(i,1)) 0 0;...
           0 0 1 L(2); 0 0 0 1];
  T10 = [T01(1:3,1:3)' -T01(1:3,1:3)'*T01(1:3,4);0 0 0 1];

  T12 = [-sin(theta(i,2)) -cos(theta(i,2)) 0 -L(1);0 0 -1 0;...
           cos(theta(i,2)) -sin(theta(i,2)) 0 0; 0 0 0 1];
  T21 = [T12(1:3,1:3)' -T12(1:3,1:3)'*T12(1:3,4);0 0 0 1];

  T23 = [cos(theta(i,3)) -sin(theta(i,3)) 0 L(3);sin(theta(i,3)) cos(theta(i,3)) 0 0;...
           0 0 1 0; 0 0 0 1];
  T32 = [T23(1:3,1:3)' -T23(1:3,1:3)'*T23(1:3,4);0 0 0 1];
  
  product = T32*T21*T10*conventionMatrixT06;
  
  if abs(product(2,3)) <= 1
    theta5 = acos(product(2,3));
  else
    warning('It is not possible to determine theta5');
    theta5 = Inf;
  end
  
  if sin(theta5) ~= 0
    theta4st = atan2(product(3,3),-product(1,3));
    theta6st = atan2(product(2,1),product(2,2));
    theta4nd = atan2(-product(3,3),product(1,3));
    theta6nd = atan2(-product(2,1),-product(2,2));
  else
    warning('The arm is in a singularity and we cannot distinguish the effect of moving joint4 and 6! (solution %d and %d)',i,2*i)
    theta4st = inf;
    theta6st = inf;
    theta4nd = inf;
    theta6nd = inf;
  end
  orientThetastSol = [orientThetastSol; theta4st theta5 theta6st];
  orientThetandSol = [orientThetandSol; theta4nd -theta5 theta6nd];
end

theta = [theta orientThetastSol; theta orientThetandSol];
theta = theta*180/pi;

end


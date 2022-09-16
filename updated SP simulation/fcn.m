function y = fcn(input1,input2,input3)

Ps = input1(1);
Th = input1(2);
Ph = input1(3);
dX = input1(4);
dY = input1(5);
dZ = input1(6);
AL = input2;
R = input3(1);
r = input3(2);
p = input3(3);
d = input3(4);
q = 5.79;    % shift of servo axis
% l = 0.0015;   % half of mount
disp(input2);
disp(input3);
rotangle = input3(5);
huj = 8.7;  % height of universal joint

AB = d;
OB = r;

Alpha = zeros(1,6);

T = [ cos(Ph)*cos(Th), cos(Ph)*sin(Ps)*sin(Th)-sin(Ph)*cos(Ps), cos(Ph)*sin(Th)*cos(Ps)-sin(Ph)*sin(Ps)
      sin(Ph)*cos(Th), sin(Ph)*sin(Ps)*sin(Th)+cos(Ph)*cos(Ps), sin(Ph)*sin(Th)*cos(Ps)-cos(Ph)*sin(Ps)
      -sin(Th),        cos(Th)*sin(Ps),                         cos(Th)*cos(Ps)                       ];
  
CL = [     96.4920   -5.7900         0
   43.2317   86.4595         0
  -43.2317   86.4595         0
  -96.4920   -5.7900         0
  -53.2603  -80.6695         0
   53.2603  -80.6695         0];
  
for ii = 1: 6
    
    tmp = [[T, [dX dY dZ]'];[0 0 0 1]] * [AL(ii,:) 1]';

    rm = [ cos(rotangle*(ii-1))  -sin(rotangle*(ii-1))   0     % rotation matrix for coordinates computing i-th leg along Z-axis
           sin(rotangle*(ii-1))   cos(rotangle*(ii-1))   0
           0                      0                      1]; 
   
%     E = abs([[rm', -rm'*[cos((ii-1)*rotangle)*(R + p) sin((ii-1)*rotangle)*(R + p) 0]'];[0 0 0 1]] * tmp);       
    E = abs(rm'*(tmp(1:3)-CL(ii,:)'));

    DO = E(2);
    DE = E(3);
    AE = E(1);
    EB = sqrt(AB^2 - AE^2);
    EO = sqrt(DO^2 + DE^2);

    Alpha_3 = acos((DO^2 + EO^2 - DE^2)/(2 * DO * EO));
    Alpha_2 = acos((EO^2 + OB^2 - EB^2)/(2 * EO * OB));

    if mod(ii,2) ~= 0
        Alpha_1 = pi - Alpha_2 - Alpha_3; %  
    else 
        Alpha_1 = Alpha_2 + Alpha_3; %
    end
    Alpha(ii) = Alpha_1 + (-1)^(ii)*asin(huj/r);
end

y = Alpha;




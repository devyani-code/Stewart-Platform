function calc_servo_angle(pitch,roll,yaw, x,y,z)
%new_list=(cell2mat(inp_list));
%platform angle
pitch=double(pitch);
roll=double(roll);
beta=20;
%servo angle
alpha=20;
%platform dimension
PD=8.08;
%base dimensions
BD=16.66;
%servoarm length;
sl=2.5;
%offset angle
of_ang=[pi/6 pi/6 -pi/2 -pi/2 pi/6 pi/6];
%angle at which servo arm lies 
theta_s=[-60 120 180 0 60 -120];
%totalangle
tot_angle_base(1)=of_ang(1)+deg2rad(alpha);
tot_angle_base(2)=of_ang(2)-deg2rad(alpha);
tot_angle_base(3)=of_ang(3)+deg2rad(alpha);
tot_angle_base(4)=of_ang(4)+deg2rad(alpha);
tot_angle_base(5)=of_ang(5)-deg2rad(alpha);
tot_angle_base(6)=of_ang(6)+deg2rad(alpha);

%connecting arm length
leg=27;
%z_home= default height
h0=26;
%input parameters


yaw=yaw;
pauseTime = 0.01;
for i=1:3
        xb(i)=BD*cos(tot_angle_base(i));
        yb(i)=BD*sin(tot_angle_base(i));
        zb(i)=0;
end
for i=4:6
        xb(i)=-BD*cos(tot_angle_base(i));
        yb(i)=BD*sin(tot_angle_base(i));
        zb(i)=0;
end
    %Calculate Platform coordinates wrt platform frame
tot_angle_pf(1)=of_ang(1)+deg2rad(beta);
tot_angle_pf(2)=of_ang(2)-deg2rad(beta);
tot_angle_pf(3)=of_ang(3)+deg2rad(beta);
tot_angle_pf(4)=of_ang(4)+deg2rad(beta);
tot_angle_pf(5)=of_ang(5)-deg2rad(beta);
tot_angle_pf(6)=of_ang(6)+deg2rad(beta);

X=x;
Y=y;
Z=z;

yaw=0;
%translation vector T
T=[X Y Z];
%Calculate base coordinates


for i=1:3
    
    xp(i)=PD*cos(tot_angle_pf(i));
    yp(i)=PD*sin(tot_angle_pf(i));
    zp(i)=h0;
end
for i=4:6
    
    xp(i)=-PD*cos(tot_angle_pf(i));
    yp(i)=PD*sin(tot_angle_pf(i));
    zp(i)=h0;
end
%%%%%%%%%%%%for j=1:count

    
    %Calculate platform coordinates wrt base frame

    for i=1:6
        xa(i)=xp(i)*cos(roll)*cos(yaw)+yp(i)*(sin(pitch)*sin(roll)*cos(roll)-cos(pitch)*sin(yaw))+T(1);
        ya(i)=xp(i)*cos(roll)*sin(yaw)+yp(i)*(cos(pitch)*cos(yaw)+sin(pitch)*sin(roll)*sin(yaw))+T(2);
        za(i)=-1*xp(i)*sin(roll)+yp(i)*sin(pitch)*cos(roll)+h0+T(3);
    end
    %calculating delta L
    for i=1:6
        del_x(i)=xb(i)-xa(i);
        del_y(i)=yb(i)-ya(i);
        del_z(i)=zb(i)-za(i);
        piston_length(i)=sqrt(del_x(i)*del_x(i)+del_y(i)^2+del_z(i)^2);

    end

    for i=1:6
        L(i)=(piston_length(i)^2)-(leg^2-sl^2);
        M(i)=2*sl*(za(i)-zb(i));
        N(i)=2*sl*(cos(deg2rad(theta_s(i)))*(xa(i)-xb(i))+sin(deg2rad(theta_s(i)))*(ya(i)-yb(i)));
        servo_angle(i)= asin(L(i)/(sqrt(M(i)*M(i)+N(i)*N(i))))-atan(N(i)/M(i));
    end
    %calculate coordinates of servo motor leg coordinate
    for i=1:6
        xs(i)=sl*cos(-servo_angle(i))*cos(deg2rad(theta_s(i)))+xb(i);
        ys(i)=sl*cos(-servo_angle(i))*sin(deg2rad(theta_s(i)))+yb(i);
        zs(i)=-sl*sin(-servo_angle(i));
    end
    disp(rad2deg(servo_angle))
    fill3(xb, yb, zb, [1,0.5,0.5]);
    hold on
    fill3(xa, ya, za, [0.5,1,1]);
    stplot(xb,yb,zb,xs,ys,zs,[0.3,0.3,0.8]);
    stplot(xs,ys,zs,xa,ya,za,[0.3,0.3,0.1]);
    hold off
    getframe;
    pause(pauseTime);
   
function stplot( x_n,y_n, z_n, xt, yt, zt,colour)

   stplotline(1, 1, x_n, y_n, z_n, xt, yt, zt, colour); 
   stplotline(2, 2, x_n, y_n, z_n, xt, yt, zt, colour);
   stplotline(3, 3, x_n, y_n, z_n, xt, yt, zt, colour);
   stplotline(4, 4, x_n, y_n, z_n, xt, yt, zt, colour);
   stplotline(5, 5, x_n, y_n, z_n, xt, yt, zt, colour);
   stplotline(6, 6, x_n, y_n, z_n, xt, yt, zt, colour);
    % Plot upper part
function stplotline( bottomPoint, topPoint, xb, yb, zb, Xt, Yt, Zt, color )
%STPLOTLINE Plots a line in space
%   Given the indices of a bottom and a top point, the base frame,
%   the upper frame and a color as parameters, stplotline plots
%   a prismatic joint for a Stewart platform.

    plot3([xb(bottomPoint),Xt(topPoint)],...
        [yb(bottomPoint),Yt(topPoint)],...
        [zb(bottomPoint),Zt(topPoint)],...
        'LineWidth',5,'Color',color);




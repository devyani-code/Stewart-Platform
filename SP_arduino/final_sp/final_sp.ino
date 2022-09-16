#include<Servo.h>
Servo servos[6];

const float pi=radians(180), of_ang[6]={pi/6, pi/6,-pi/2,-pi/2,pi/6,pi/6},tot_angle_base[6]={0.994837674,0.052359878,-1.099557429,-1.099557429,0.052359878,0.994837674},tot_angle_pf[6]={  0.994837674,0.052359878,-1.099557429,-1.099557429,0.052359878,0.994837674};
const int alpha=27,beta=27,PD=8.08,BD=16.66,sl=2,theta_s[6]={-60,120,180,0,60,-120},leg=27,h0=26,pauseTime=0.01;
int i;
float X,Y,Z;
float xb[6],yb[6],zb[6];
float T[3];
float xp[6],yp[6],zp[6];
float xa[6],ya[6],za[6];
float del_x[6],del_y[6],del_z[6];
float piston_length[6],L[6],M[6],N[6],servo_angle[6];
float deg=180/pi;
float var_even=180;
float var_odd=0;
int poses[]={90,90,90,90,90};
int pitch,yaw,roll;
float x,y,z;

float* calculations( float pitch, float roll,float yaw,float x,float y, float z){
  T[0]=x;
  T[1]=y;
  T[2]=z;
  for(i=0;i<3;i++){
    xb[i]=BD*cos(tot_angle_base[i]);
    yb[i]=BD*sin(tot_angle_base[i]);
    zb[i]=0;
  }
  for(i=3;i<6;i++){
    xb[i]=-BD*cos(tot_angle_base[i]);
    yb[i]=BD*sin(tot_angle_base[i]);
    zb[i]=0;
    
  }
  
  for(i=0;i<3;i++){
    xp[i]=PD*cos(tot_angle_pf[i]);
    yp[i]=PD*sin(tot_angle_pf[i]);
    zp[i]=h0;
  }
  for(i=3;i<6;i++){
    xp[i]=-PD*cos(tot_angle_pf[i]);
    yp[i]=PD*sin(tot_angle_pf[i]);
    zp[i]=h0;
  }

  for(i=0;i<6;i++){
    xa[i]=xp[i]*cos(roll)*cos(yaw)+yp[i]*(sin(pitch)*sin(roll)*cos(roll)-cos(pitch)*sin(yaw))+T[0];
    ya[i]= xp[i]*cos(roll)*sin(yaw)+yp[i]*(cos(pitch)*cos(yaw)+sin(pitch)*sin(roll)*sin(yaw)) +T[1];
    za[i]=-1*xp[i]*sin(roll)+yp[i]*sin(pitch)*cos(roll)+h0+T[2];
  }
  for(i=0;i<6;i++){
      del_x[i]=xb[i]-xa[i];
      del_y[i]=yb[i]-ya[i];
      del_z[i]=zb[i]-za[i];
      piston_length[i]=sqrt(del_x[i]*del_x[i]+del_y[i]*del_y[i]+del_z[i]*del_z[i]);

  }
  for(i=0;i<6;i++){
      L[i]=sq(piston_length[i])-(sq(leg)-sq(sl));
      M[i]=2*sl*(za[i]-zb[i]);
      N[i]=2*sl*(cos(theta_s[i]*pi/180)*(xa[i]-xb[i])+sin(theta_s[i]*pi/180)*(ya[i]-yb[i]));
      servo_angle[i]=asin(L[i]/(sqrt(sq(M[i])+sq(N[i]))))-atan(N[i]/M[i]);
  }
  
  for(int i=0;i<6;i++){
    if(i%2==0){
      servo_angle[i]=90+deg*servo_angle[i];
      servo_angle[i] = constrain(servo_angle[i], 25, 180);
    }
    else if(i%2==1){
      servo_angle[i]=90-deg*servo_angle[i];
      servo_angle[i] = constrain(servo_angle[i], 0, 155);
    }
  }
  float* var=servo_angle;
  return servo_angle;
}

void setup() {
   Serial.begin(9600);
   servos[0].attach(3);
   servos[1].attach(5);
   servos[2].attach(6);
   servos[3].attach(9);
   servos[4].attach(10);
   servos[5].attach(11);
}

void loop() {
  // put your main code here, to run repeatedly:

  float* angles;
//  Serial.println("Enter pitch angle: ");
//  while(Serial.available() == 0){};
//  pitch = Serial.readString().toInt();
//  Serial.println(pitch);
//  
//  Serial.println("Enter roll angle: ");
//  while(Serial.available() == 0){};
//  roll = Serial.readString().toInt();
//  Serial.println(roll);
//
//  Serial.println("Enter yaw angle: ");
//  while(Serial.available() == 0){};
//  yaw = Serial.readString().toInt();
//  Serial.println(yaw);
//
//  Serial.println("Enter x : ");
//  while(Serial.available() == 0){};
//  x = Serial.readString().toFloat();
//  Serial.println(x);
//
//  Serial.println("Enter y: ");
//  while(Serial.available() == 0){};
//  y = Serial.readString().toFloat();
//  Serial.println(y);
//
//  Serial.println("Enter z: ");
//  while(Serial.available() == 0){};
//  z = Serial.readString().toFloat();
//  Serial.println(z);
//  
  // translation in z- max=1.5, min=-2;
  //pit max=20 when other angles=0; else max=5
  //roll max=20;when other angles=0; else max=5 
  //yaw max=7 when other angles are 0; else 
  //roll along x axis;
  //pitch along y;

 
 
  angles=calculations(radians(5),radians(0),radians(0),0,0,0);
  
  for(int i=0;i<6;i++){
    if(isnan(angles[i])){
      Serial.println("no");
      exit(0);
    }
  }

 Serial.println(angles[1]);
 
  for(int i=0;i<6;i++){
    float final_pose = angles[i];
    if(final_pose>=poses[i]){
      for(int pos=poses[i];pos<=final_pose;pos++){
        servos[i].write(pos);
        poses[i]=pos;
        delay(40);
      }
    }
    else{
      for(int pos=poses[i]; pos>=final_pose;pos--){
        servos[i].write(pos);
        poses[i]=pos;
        delay(40);
      }
    }
    
  }
  
  delay(6000);

}

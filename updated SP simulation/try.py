from re import M
import matlab.engine
m1 = matlab.engine.start_matlab()
for i in range(0,10):
    m1.calc_servo_angle(1,nargout=0)


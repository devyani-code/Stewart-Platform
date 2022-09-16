from math import factorial
from cv2 import destroyAllWindows
from utils import *
# from count_fingers import *
from predict import *
from run_avg import *
from segment import *
# from global_vars import *
import matlab.engine
eng = matlab.engine.start_matlab()
inp_list=[]
def gen_video():
    roll=0
    pitch=0
    aWeight = 0.1
    bg = None;
    camera = cv2.VideoCapture(0)
    top, right, bottom, left = 10, 350, 225, 590
    num_frames = 0
    num = 1
    i = 1

    while(True):

        (grabbed, frame) = camera.read()
        frame = imutils.resize(frame, width=700)
        frame = cv2.flip(frame, 1)
        clone = frame.copy()

        (height, width) = frame.shape[:2]
        roi = frame[top:bottom, right:left]
        gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (7, 7), 0)

        if num_frames < 50:
            bg = RunAvg(gray, aWeight,bg)

        else:
            if (num_frames == 50):
                print(''' 

                Background Readed
                
                We are good to Go !!!
                
                ''')
            
            hand = segment(gray,bg)
            if hand is not None:
                (thresholded, segmented) = hand
                if(num_frames%2==0):
                    res = predicto(thresholded)
                
                    if res=='front' and roll<0.6:
                        roll=roll+0.01
                    
                    if res=='back' and roll>-0.6:
                        roll=roll-0.01
                    
                    if res=='left' and pitch<0.6:
                        pitch=pitch+0.01
                    
                    if res=='right' and pitch>-0.6:
                        pitch=pitch-0.01

                eng.calc_servo_angle(pitch,roll,nargout=0)   
                
                cv2.drawContours(clone, [segmented + (right, top)], -1, (0, 0, 255))
                cv2.putText(clone, res, (70, 85), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,0,255), 2)
                cv2.imshow("Thesholded", thresholded)
                
                num += 1

        cv2.rectangle(clone, (left, top), (right, bottom), (0,255,0), 2)
        num_frames += 1
        cv2.imshow("Video Feed", clone)
        keypress = cv2.waitKey(1) & 0xFF
        if num_frames == 100000:
            break        
gen_video()


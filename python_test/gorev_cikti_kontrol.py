import numpy as np
import cv2 

liste=[]

file = open('D:/vivado/gorev_cikti.txt','r')
for i in file:
    liste.append(i)
file.close()
liste=np.array(liste)

a = np.reshape(liste,(240,320))
a=np.uint8(a)

cv2.imshow("Gorev3 - FPGA Ciktisi",a)

cv2.waitKey(0)
cv2.destroyAllWindows()

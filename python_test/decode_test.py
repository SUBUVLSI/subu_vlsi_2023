import numpy as np
import cv2
#image=cv2.imread('C:/Users/PC/Desktop/image_compression/football_Qvga.tif')
#image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

#cv2.imshow("orijinal",image) 

liste=[]
#file = open("C:/Users/HP/Downloads/cikti.txt","r")
file = open("D:/vivado/cikti.txt","r")
for i in file:
    a=float(i)
    b=int(a)
    liste.append(b)
file.close() 
resim=np.zeros((240,320))
matris=[]
i=0
while i < len(liste):
    temp=[]
    for j in range(64):
        temp.append(liste[i+j])
    temp = np.array(temp)
    a= np.reshape(temp,(8,8))
    matris.append(np.uint8(a))
    i = i + 64
j=0
genislik=resim.shape[1]
yukseklik=resim.shape[0]
while j < 1200:
    for a in range(0,yukseklik,8):
        for b in range(0,genislik,8):
            resim[a:a+8 , b:b+8] = matris[j]
            j=j+1
            
            
resim=np.uint8(resim)            
cv2.imshow("Decode - Verilog Ciktisi",resim)   


cv2.waitKey(0)
cv2.destroyAllWindows()
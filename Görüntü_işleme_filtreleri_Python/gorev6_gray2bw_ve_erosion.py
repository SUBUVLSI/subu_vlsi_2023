import numpy as np
import cv2 

image = cv2.imread("C:/Users/PC/Desktop/t/image_compression/football_Qvga.tif")
image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

genislik=image.shape[1]
yukseklik=image.shape[0] 

img=np.zeros((240,320))

otsu=np.zeros((242,322))
for i in range(yukseklik):
    for j in range(genislik):
        if image[i][j] < 140:
            img[i][j] = 0
        elif image[i][j] >= 140:
            img[i][j] = 255
            
otsu[1:241 , 1:321] = img
cv2.imshow("treshold",otsu)

yukseklik1=otsu.shape[0]
genislik1=otsu.shape[1]

kernel=[[1,1,1],
        [1,1,1],
        [1,1,1]]

erosion_filtre = np.zeros(shape=(yukseklik, genislik))

for i in range (0,yukseklik1-2):
    for j in range (0,genislik1-2):
        liste=[]
        liste.append(otsu[i][j]*kernel[0][0]) 
        liste.append(otsu[i][j+1]*kernel[0][1])
        liste.append(otsu[i][j+2]*kernel[0][2])
        liste.append(otsu[i+1][j]*kernel[1][0]) 
        liste.append(otsu[i+1][j+1]*kernel[1][1]) 
        liste.append(otsu[i+1][j+2]*kernel[1][2])
        liste.append(otsu[i+2][j]*kernel[2][0])
        liste.append(otsu[i+2][j+1]*kernel[2][1]) 
        liste.append(otsu[i+2][j+2]*kernel[2][2])
        for k in liste:
            if (k == 255):
                a=255
                continue
            elif (k == 0):
                a=0
                break
        erosion_filtre[i][j]=a
cv2.imshow("erosion",erosion_filtre)

last=np.zeros((240,320))        
for i in range(yukseklik):
     for j in range(genislik):
         last[i][j] = img[i][j]-erosion_filtre[i][j] 
         if last[i][j] < 0:
             last[i][j] = 0
             
last = np.uint8(last)  

cv2.imshow("Gorev6 Python",last)    
cv2.waitKey(1)      
        
        
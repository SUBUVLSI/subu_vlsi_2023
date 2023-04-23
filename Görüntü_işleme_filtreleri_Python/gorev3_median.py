import numpy as np
import cv2 

img = cv2.imread("C:/Users/PC/Desktop/t/image_compression/football_Qvga.tif")

#cv2.imshow("Original image",img)
#print(img.shape)

img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

genislik=img.shape[1]
yukseklik=img.shape[0] 

median_son=np.zeros((yukseklik,genislik))
for i in range (0,yukseklik-2):
    for j in range (0,genislik-2):
        liste=[]
        liste.append(img[i][j])
        liste.append(img[i][j+1])
        liste.append(img[i][j+2])
        liste.append(img[i+1][j])
        liste.append(img[i+1][j+1])
        liste.append(img[i+1][j+2])
        liste.append(img[i+2][j])
        liste.append(img[i+2][j+1])
        liste.append(img[i+2][j+2])
        liste.sort()
        median_son[i+1][j+1]=liste[4]
median_son=np.uint8(median_son)  
   
cv2.imshow("Gorev3 Python",median_son)  

cv2.waitKey(1)     
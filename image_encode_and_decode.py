#import libraries
import numpy as np
import cv2 
from image_compression_functions import *
from image_decode_functions import *

#load image and convert to grayscale
image=cv2.imread('C:/Users/PC/Desktop/t/image_compression/football_Qvga.tif')
image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

cv2.imshow("Original Image",image)

genislik=image.shape[1]
yukseklik=image.shape[0] 

decode_image=np.zeros((240,320))

decode_sonucu=[]
encode_sonucu=[]
resim_blokları=[]
for a in range (0,yukseklik,8):
    for b in range (0,genislik,8):
        img=image[a:a+8,b:b+8]
        resim_blokları.append(img)
        img=np.float16(img)
        block=img-128
        #dct
        dct_islemi=dct(block)
        #kuantalama
        kuantalama=quantazation(dct_islemi)
        encode_sonucu.append(kuantalama)
        inv_kuantalamaa= inv_kuantalama(kuantalama)
        inv_dct= IDCT(inv_kuantalamaa)
        sonn= yuzyirmisekiz(inv_dct)
        for i in range(sonn.shape[0]):
            for j in range(sonn.shape[1]):
                if sonn[i][j] < 0:
                    sonn[i][j] = 0
                elif sonn[i][j] > 255:
                    sonn[i][j] = 255
        decode_sonucu.append(sonn)
        decode_image[a:a+8,b:b+8] = np.uint8(sonn)
        
     
decode_image=np.uint8(decode_image)

cv2.imshow("Decode Python",decode_image) 

cv2.waitKey(1)
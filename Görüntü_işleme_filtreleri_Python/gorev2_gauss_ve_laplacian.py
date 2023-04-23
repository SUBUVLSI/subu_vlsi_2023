import numpy as np
import cv2 


liste=[]
file = open("C:/Users/PC/Desktop/gorev2_tb (24).txt","r")
for i in file:
    liste.append(np.uint8(i))
a=np.reshape(liste,(240,320))
b = a
cv2.imshow("Gorev2 Verilog",b)

img = cv2.imread("C:/Users/PC/Desktop/t/image_compression/football_Qvga.tif")
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
cv2.imshow("Orijinal Resim",img)


height=img.shape[0]
width=img.shape[1]



kernel_gauss = [[1/16, 1/8, 1/16],   
                [ 1/8, 1/4,  1/8],
                [1/16, 1/8, 1/16]]
gaussian_filtre = np.zeros(shape=(height-2, width-2))
for i in range (0,height-2):
    for j in range (0,width-2):
        block=img[i:i+3 , j:j+3]
        gaussian_filtre[i][j]=np.sum(np.multiply(block,kernel_gauss))
        gaussian_filtre[i][j] = round(gaussian_filtre[i][j])

yukseklik=gaussian_filtre.shape[0]
genislik=gaussian_filtre.shape[1]

kernel_laplacian=[[-1, -1, -1],
                  [-1,  8, -1],
                  [-1, -1, -1]]

laplacian_filtre = np.zeros(shape=(yukseklik-2, genislik-2))
for i in range (0,yukseklik-2):
    for j in range (0,genislik-2):
        block = gaussian_filtre[i:i+3 , j:j+3]
        convolution = np.sum(np.multiply(block,kernel_laplacian))
        
        if convolution < 0:
            convolution = 0
        elif convolution > 255:
            convolution = 255
        
        laplacian_filtre[i][j] = convolution
log_filtre=np.zeros((height,width))

log_filtre[2:height-2,2:width-2] = laplacian_filtre

#cv2.imshow("Laplacian",np.uint8(log_filtre))

toplama=np.zeros((height,width))
for i in range(height):
    for j in range(width):
        toplama[i][j] = img[i][j] + log_filtre[i][j] 
        if toplama[i][j] > 255 :
            toplama[i][j] = 255
        
toplama = np.uint8(toplama)      

cv2.imshow("Gorev2 Python",toplama)

cv2.waitKey(1)
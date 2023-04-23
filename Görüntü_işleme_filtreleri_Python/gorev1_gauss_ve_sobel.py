import numpy as np
import cv2 

img = cv2.imread("C:/Users/PC/Desktop/t/image_compression/football_Qvga.tif")
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

height=img.shape[0]
width=img.shape[1]
 

kernel = [[1/16, 1/8, 1/16],   
          [1/8, 1/4, 1/8],
          [1/16, 1/8, 1/16]]

gaussian_filtre = np.zeros(shape=(height-2, width-2))

for i in range (0,height-2):
    for j in range (0,width-2):
        block=img[i:i+3 , j:j+3]
        gaussian_filtre[i][j]=np.sum(np.multiply(block,kernel))
        gaussian_filtre[i][j] = round(gaussian_filtre[i][j])
        
gaussian_filtre = np.uint8(gaussian_filtre)              


yukseklik=gaussian_filtre.shape[0]
genislik=gaussian_filtre.shape[1]

kernelx = [[-1,  0,  1],
           [-2,  0,  2], 
           [-1,  0,  1]]


kernely = [[-1, -2, -1], 
           [ 0,  0,  0], 
           [ 1,  2,  1]]


sobel_bitwise = np.zeros((yukseklik-2,genislik-2))
sobel_bitwise_or = np.zeros((height,width))
sobel_x_y= np.zeros((yukseklik-2,genislik-2))
sobel_hipotenus = np.zeros((height,width))       
for i in range (0,yukseklik-2):
    for j in range (0,genislik-2):   
        block = gaussian_filtre[i:i+3 , j:j+3]
        convolution_x = np.sum(np.multiply(block,kernelx))
        convolution_y = np.sum(np.multiply(block,kernely))
        sobel_x_y[i][j] = ((convolution_x**2 + convolution_y**2)**(1/2))
        if convolution_x>255:
            convolution_x=255
        elif convolution_x < 0:
            convolution_x = 0
        if convolution_y>255:
            convolution_y = 255
        elif convolution_y < 0:
            convolution_y = 0
        sobel_bitwise[i][j]= convolution_x | convolution_y
        if sobel_bitwise[i][j] > 255:
            sobel_bitwise[i][j] = 255
        elif sobel_bitwise[i][j] < 0:
            sobel_bitwise[i][j] = 0
            
#Hiptenus
minn=np.amin(sobel_x_y)
maxx=np.amax(sobel_x_y)
sobel_x_y = np.floor((sobel_x_y-minn)/(maxx-minn)*255.0)
sobel_hipotenus[2:height-2,2:width-2] = sobel_x_y
sobel_hipotenus=np.uint8(sobel_hipotenus)
            
#Bitwise
sobel_bitwise_or[2:height-2,2:width-2] = sobel_bitwise
sobel_bitwise_or=np.uint8(sobel_bitwise_or)
cv2.imshow("Gorev1 Python",sobel_bitwise_or)

cv2.waitKey(1)


 

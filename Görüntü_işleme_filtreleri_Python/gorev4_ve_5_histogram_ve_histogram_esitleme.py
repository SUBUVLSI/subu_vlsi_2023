import numpy as np
import cv2
import copy
import matplotlib.pyplot as plt

img = cv2.imread("C:/Users/PC/Desktop/t/image_compression/football_Qvga.tif")
img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
#cv2.imshow("Original Image",img)

height = img.shape[0]
width = img.shape[1]

histogram = [0] * 256

for i in range(height):
    for j in range(width):
        histogram[img[i][j]] += 1


plt.figure(figsize= (7,7))
pixels = np.linspace(0,255,256,dtype="int16")
plt.subplot(1, 1,1)
plt.plot(pixels,histogram)
plt.fill_between(pixels,histogram)
plt.title("Gorev4 Python")
plt.show()

for i in histogram:
    if i != 0:
        cdf_min = i
        break
    
cdf = copy.deepcopy(histogram)    
count = 0    
for i in range(len(cdf)):
    count = count + histogram[i]
    cdf[i] = count
    
mxn = height * width

h = copy.deepcopy(cdf)
for i in range(len(h)):
    h[i] = round(((cdf[i] - cdf_min) / (mxn - cdf_min)) * 255)
    
    
for i in range(height):
    for j in range(width): 
            a = img[i][j]
            img[i][j] = h[a]
            
cv2.imshow("Gorev5 Python",img)             


histogram_e = [0] * 256
for i in range(height):
    for j in range(width):
        histogram_e[img[i][j]] += 1
        

pixels = np.linspace(0,255,256,dtype="int16")            
plt.plot(pixels,histogram_e)
plt.fill_between(pixels,histogram_e)
plt.title("Gorev5 Esitlenmis Histogram")
plt.show()
  
 
cv2.waitKey(1)
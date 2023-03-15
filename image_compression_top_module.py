#import libraries
import numpy as np
import cv2 
import copy
from image_compression_functions import *

#load image and convert to grayscale
image=cv2.imread('C:/Users/PC/Desktop/t/image_compression/football_Qvga.tif')
image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

#define height and width
genislik=image.shape[1]
yukseklik=image.shape[0] 
     
zigzag_sonucu=[]
for a in range (0,yukseklik,8):
    for b in range (0,genislik,8):
        
        img=image[a:a+8,b:b+8]
        img=np.float16(img)
        block=img-128
        #dct
        dct_islemi=dct(block)
        #kuantalama
        kuantalama=quantazation(dct_islemi)
        #zigzag
        zigzag_tarama=zigzag(kuantalama)   
        zigzag_sonucu.append(zigzag_tarama)

#Dpcm
dpcm=copy.deepcopy(zigzag_sonucu)        
for i in range (1199):
    dpcm[i+1][0]=zigzag_sonucu[i+1][0]-zigzag_sonucu[i][0]
#Run-length       
run_length_islemi=[]    
for i in range (1200):
    a=dpcm[i]
    run_length_islemi.append(run_length(a))
        
huffman=copy.deepcopy(run_length_islemi)


for i in range(1200):
    a=len(run_length_islemi[i])
    for j in range (a):
        if (len(run_length_islemi[i][j]) == 2):
            huffman[i][j][0]=dc_size_code(run_length_islemi[i][j][0])
            run_length_islemi[i][j][1]=int(run_length_islemi[i][j][1])
            huffman[i][j][1]=ones_compliment(run_length_islemi[i][j][1])
        elif (len(run_length_islemi[i][j]) == 3):
            run_length_islemi[i][j][0]=int(run_length_islemi[i][j][0])
            run_length_islemi[i][j][1]=int(run_length_islemi[i][j][1])
            run_length_islemi[i][j][2]=int(run_length_islemi[i][j][2])
            huffman[i][j][2] = ones_compliment(run_length_islemi[i][j][2])
            huffman[i][j][0] = ac_zero_size_code(run_length_islemi[i][j][0],run_length_islemi[i][j][1])
            del huffman[i][j][1] 
        elif (len(run_length_islemi[i][j]) == 1):
            if ( run_length_islemi[i][j][0] == 'eob'):
                huffman[i][j] = ['1010']
            elif (run_length_islemi[i][j] == [16]) :
                huffman[i][j] = ['11111111001']
            else:
                print("hata1")
        else:
            print("hata2")
            
#final bitstream           
bitstream=[] 
for i in range(1200):
    a=len(huffman[i])
    for j in range (a):
        b=len(huffman[i][j])
        for k in range(b):
            if (huffman[i][j][k] != str(huffman[i][j][k])):
                print("hata3")
            bitstream.append(huffman[i][j][k])

#to write bitstream on a single line
while('' in bitstream):
    bitstream.remove('')
s = ''.join(bitstream)


#for creating files
uzunluk = len(s)
true = True
while true :
    if (((uzunluk/8) % 1) == 0):
        true= False
    else:
        s = s + '0'
        uzunluk = uzunluk +1 
 
#for txt files     
with open("C:/Users/PC/Desktop/python_image_bitstream.txt", "w") as f:
    f.write(s)     

#for simulation tests
byte_otuziki=[]
j=0
while j < len(s):
    byte_otuziki.append(s[j:j+32])
    j += 32
with open("C:/Users/PC/Desktop/python_image_bitstream_simulation.txt", "w") as f:
    for byte in byte_otuziki:
        f.write(byte + "\n")

#for bin files             
i = 0
buffer = bytearray()
while i < len(s):
    buffer.append( int(s[i:i+8] , 2) )
    i += 8
with open('C:/Users/PC/Desktop/python_image_bitsream.bin', 'bw') as f:
    f.write(buffer)    

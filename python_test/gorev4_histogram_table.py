import numpy as np
import matplotlib.pyplot as plt


liste=[]
file = open("D:/vivado/gorev4_cikti.txt","r")
for i in file:
    liste.append(i)
liste2=[]
for i in range(len(liste)):
    liste2.append(int(liste[i][8:],2))

plt.figure(figsize= (7,7))
plt.subplot(1, 1, 1)
pixels = np.linspace(0,255,256,dtype="int16")
plt.plot(pixels,liste2)
plt.fill_between(pixels,liste2)
plt.title("Gorev4 - FPGA Ciktisi")
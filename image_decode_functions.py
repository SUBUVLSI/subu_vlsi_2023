import numpy as np
import math


quantization=[[16, 11, 10, 16,  24,  40,  51,  61],
              [12, 12, 14, 19,  26,  58,  60,  55],
              [14, 13, 16, 24,  40,  57,  69,  56],
              [14, 17, 22, 29,  51,  87,  80,  62],
              [18, 22, 37, 56,  68, 109, 103,  77],
              [24, 35, 55, 64,  81, 104, 113,  92],
              [49, 64, 78, 87, 103, 121, 120, 101],
              [72, 92, 95, 98, 112, 100, 103,  99]]
T= [[0.124999999999, 0.176776695296, 0.176776695296, 0.176776695296, 0.176776695296, 0.176776695296, 0.176776695296, 0.176776695296],
    [0.176776695296, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
    [0.176776695296, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
    [0.176776695296, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
    [0.176776695296, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
    [0.176776695296, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
    [0.176776695296, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
    [0.176776695296, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25]]


def inv_kuantalama(matris):
    m=matris.shape[0]
    n=matris.shape[1]
    idct= np.zeros((m,n))
    for i in range(m):
        for j in range(n):
            idct[i][j]=matris[i][j]*quantization[i][j]    
    return idct

def IDCT(inputt):
    m=inputt.shape[0]
    n=inputt.shape[1]
    tmp_summ=[]
    tmp_output = np.zeros((8, 8))
    for x  in range(m):
        for y  in range(n):
            tmp_sum = 0
            for u  in range(m):
                for v  in range(n):
                    idct = inputt[u][v] * math.cos((2 * x + 1) * u * math.pi / (2 * m)) * math.cos((2 * y + 1) * v * math.pi / (2 * n))
                    tmp_sum += T[u][v] * idct
            tmp_summ.append(tmp_sum)
            tmp_output[x][y] = tmp_sum
    return tmp_output

def yuzyirmisekiz(matris):
    m=matris.shape[0]
    n=matris.shape[1]
    son = np.zeros((m,n))
    for i in range(m):
        for j in range(n):
            son[i][j]=round(matris[i][j]+128)     
    return son        
    

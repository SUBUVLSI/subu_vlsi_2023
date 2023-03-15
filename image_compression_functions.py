# MODULES FOR IMAGE COMPRESSION (JPEG STANDART)

#Import Libraries
import math
import numpy as np

#dct implementation DCT: Discrete Cosine Transform (Ayrık kosinüs dönüşümü)

def dct(matrix):
    if not matrix.shape[0] == matrix.shape[1]:
        raise Exception("Given array must be 8x8 matrix")
    else:
        m=matrix.shape[0]
        n=matrix.shape[1]
        T= [[0.124999, 0.176776, 0.176776, 0.176776, 0.176776, 0.176776, 0.176776, 0.176776],
            [0.176776, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
            [0.176776, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
            [0.176776, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
            [0.176776, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
            [0.176776, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
            [0.176776, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25],
            [0.176776, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25]]
        dct = np.zeros(shape=(m, n))
        for i in range(m):
            for j in range(n):
                sum=0
                for k in range(m):
                    for l in range(n):
                        dct1=matrix[k][l] * math.cos((2 * k + 1) * i * math.pi / (2 * m))* math.cos((2 * l + 1) * j * math.pi / (2 * n))
                        sum = sum + dct1
                        dct[i][j] = T[i][j] * sum
                        
    return  dct


def quantazation(matrix):
    matrix=np.array(matrix)    
    if not matrix.shape[0] == matrix.shape[1]:
        raise Exception("Given array must be 8x8 matrix")
    else:
        m=matrix.shape[0]
        n=matrix.shape[1]
        
        quantization=[[16, 11, 10, 16, 24 , 40 , 51 , 61 ],
                      [12, 12, 14, 19, 26 , 58 , 60 , 55 ],
                      [14, 13, 16, 24, 40 , 57 , 69 , 56 ],
                      [14, 17, 22, 29, 51 , 87 , 80 , 62 ],
                      [18, 22, 37, 56, 68 , 109, 103, 77 ],
                      [24, 35, 55, 64, 81 , 104, 113, 92 ],
                      [49, 64, 78, 87, 103, 121, 120, 101],
                      [72, 92, 95, 98, 112, 100, 103, 99 ]]
        for i in range(m):
            for j in range(n):
                matrix[i][j]=round(matrix[i][j]/quantization[i][j]) 
                matrix[i][j]=int(matrix[i][j])
    return matrix        

def zigzag(matrix: np.ndarray) -> np.ndarray:
    h = 0
    v = 0
    v_min = 0
    h_min = 0
    v_max = matrix.shape[0]
    h_max = matrix.shape[1]
    i = 0
    output = np.zeros((v_max * h_max))

    while (v < v_max) and (h < h_max):
        if ((h + v) % 2) == 0:  # going up
            if v == v_min:
                output[i] = matrix[v, h]  # first line
                if h == h_max:
                    v = v + 1
                else:
                    h = h + 1
                i = i + 1
            elif (h == h_max - 1) and (v < v_max):  # last column
                output[i] = matrix[v, h]
                v = v + 1
                i = i + 1
            elif (v > v_min) and (h < h_max - 1):  # all other cases
                output[i] = matrix[v, h]
                v = v - 1
                h = h + 1
                i = i + 1
        else:  # going down
            if (v == v_max - 1) and (h <= h_max - 1):  # last line
                output[i] = matrix[v, h]
                h = h + 1
                i = i + 1
            elif h == h_min:  # first column
                output[i] = matrix[v, h]
                if v == v_max - 1:
                    h = h + 1
                else:
                    v = v + 1
                i = i + 1
            elif (v < v_max - 1) and (h > h_min):  # all other cases
                output[i] = matrix[v, h]
                v = v + 1
                h = h - 1
                i = i + 1
        if (v == v_max - 1) and (h == h_max - 1):  # bottom right element
            output[i] = matrix[v, h]
            break 
    return output
    
def size(number):
    if (number==0):
        return 0
    elif (number==1 or number==-1):
        return 1
    elif (number==-3 or number==-2 ):
        return 2
    elif ( number==2 or number==3):
        return 2
    elif (-7<=number<=-4 or 4<=number<=7):
        return 3
    elif (-15<=number<=-8 or 8<=number<=15):
        return 4
    elif (-31<=number<=-16 or 16<=number<=31):
        return 5
    elif (-63<=number<=-32 or 32<=number<=63):
        return 6
    elif (-127<=number<=-64 or 64<=number<=127):
        return 7 
    elif (-255<=number<=-128 or 128<=number<=255):
        return 8
    elif (-511<=number<=-256 or 256<=number<=511):
        return 9
    elif (-1023<=number<=-512 or 512<=number<=1023):
        return 10
    elif (-2047<=number<=-1024 or 1024<=number<=2047):
        return 11
    
    
            
def dc_size_code (dc_size):
    if (dc_size == 0):
        return '00'
    elif (dc_size==1):
        return '010'
    elif (dc_size==2):
        return '011'
    elif (dc_size==3):
        return '100'
    elif (dc_size==4):
        return '101'
    elif (dc_size==5):
        return '110'
    elif (dc_size==6):
        return '1110'
    elif (dc_size==7):
        return '11110'
    elif (dc_size==8):
        return '111110'
    elif (dc_size==9):
        return '1111110'
    elif (dc_size==10):
        return '11111110'
    elif (dc_size==11):
        return '111111110'  
    
def ones_compliment(a):
    if (a==0):
        return ''
    elif (a<0):
        b= -1 * a
        bits = str(bin(b)[2:])
        filp_bits = bits.replace('1','x')
        filp_bits = filp_bits.replace('0','1')
        filp_bits = filp_bits.replace('x','0')
        return filp_bits
    elif (a>0):
        return bin(a)[2:]
    
def ac_zero_size_code (zero_count,ac_value):
    if zero_count == 0 :
        if ac_value == 1 :
            return'00'
        elif ac_value == 2 :
            return'01'
        elif ac_value == 3 :
            return'100'    
        elif ac_value == 4 :
            return'1011'
        elif ac_value == 5 :
            return'11010'
        elif ac_value == 6 :
            return'1111000' 
        elif ac_value == 7 :
            return'11111000'     
        elif ac_value == 8 :
            return'1111110110'       
        elif ac_value == 9 :
            return'1111111110000010' 
        elif ac_value == 10 :
            return'1111111110000011'    
        else :
            return'hata kontrl et'
 
    
    elif zero_count == 1 :
        if ac_value == 1 :
            return'1100'
        elif ac_value == 2 :
            return'11011'
        elif ac_value == 3 :
            return'1111001'    
        elif ac_value == 4 :
            return'111110110'
        elif ac_value == 5 :
            return'11111110110'
        elif ac_value == 6 :
            return'1111111110000100' 
        elif ac_value == 7 :
            return'1111111110000101'     
        elif ac_value == 8 :
            return'1111111110000110'       
        elif ac_value == 9 :
            return'1111111110000111' 
        elif ac_value == 10 :
            return'1111111110001000'    
        else :
            return'hata kontrl et'
    
    elif zero_count == 2 :
        if ac_value == 1 :
            return'11100'
        elif ac_value == 2 :
            return'11111001'
        elif ac_value == 3 :
            return'1111110111'    
        elif ac_value == 4 :
            return'111111110100'
        elif ac_value == 5 :
            return'1111111110001001'
        elif ac_value == 6 :
            return'1111111110001010' 
        elif ac_value == 7 :
            return'1111111110001011'     
        elif ac_value == 8 :
            return'1111111110001100'       
        elif ac_value == 9 :
            return'1111111110001101' 
        elif ac_value == 10 :
            return'1111111110001110'    
        else :
            return'hata kontrl et'

    elif zero_count == 3 :
        if ac_value == 1 :
            return'111010'
        elif ac_value == 2 :
            return'111110111'
        elif ac_value == 3 :
            return'111111110101'    
        elif ac_value == 4 :
            return'1111111110001111'
        elif ac_value == 5 :
            return'1111111110010000'
        elif ac_value == 6 :
            return'1111111110010001' 
        elif ac_value == 7 :
            return'1111111110010010'     
        elif ac_value == 8 :
            return'1111111110010011'       
        elif ac_value == 9 :
            return'1111111110010100' 
        elif ac_value == 10 :
            return'1111111110010101'    
        else :
            return'hata kontrl et'

    elif zero_count == 4 :
        if ac_value == 1 :
            return'111011'
        elif ac_value == 2 :
            return'1111111000'
        elif ac_value == 3 :
            return'1111111110010110'    
        elif ac_value == 4 :
            return'1111111110010111'
        elif ac_value == 5 :
            return'1111111110011000'
        elif ac_value == 6 :
            return'1111111110011001' 
        elif ac_value == 7 :
            return'1111111110011010'     
        elif ac_value == 8 :
            return'1111111110011011'       
        elif ac_value == 9 :
            return'1111111110011100' 
        elif ac_value == 10 :
            return'1111111110011101'    
        else :
            return'hata kontrl et'
            
    elif zero_count == 5 :
        if ac_value == 1 :
            return'1111010'
        elif ac_value == 2 :
            return'11111110111'
        elif ac_value == 3 :
            return'1111111110011110'    
        elif ac_value == 4 :
            return'1111111110011111'
        elif ac_value == 5 :
            return'1111111110100000'
        elif ac_value == 6 :
            return'1111111110100001' 
        elif ac_value == 7 :
            return'1111111110100010'     
        elif ac_value == 8 :
            return'1111111110100011'       
        elif ac_value == 9 :
            return'1111111110100100' 
        elif ac_value == 10 :
            return'1111111110100101'    
        else :
            return'hata kontrl et'
            
    elif zero_count == 6 :
        if ac_value == 1 :
            return'1111011'
        elif ac_value == 2 :
            return'111111110110'
        elif ac_value == 3 :
            return'1111111110100110'    
        elif ac_value == 4 :
            return'1111111110100111'
        elif ac_value == 5 :
            return'1111111110101000'
        elif ac_value == 6 :
            return'1111111110101001' 
        elif ac_value == 7 :
            return'1111111110101010'     
        elif ac_value == 8 :
            return'1111111110101011'       
        elif ac_value == 9 :
            return'1111111110101100' 
        elif ac_value == 10 :
            return'1111111110101101'    
        else :
            return'hata kontrl et'

    elif zero_count == 7 :
        if ac_value == 1 :
            return'11111010'
        elif ac_value == 2 :
            return'111111110111'
        elif ac_value == 3 :
            return'1111111110101110'    
        elif ac_value == 4 :
            return'1111111110101111'
        elif ac_value == 5 :
            return'1111111110110000'
        elif ac_value == 6 :
            return'1111111110110001' 
        elif ac_value == 7 :
            return'1111111110110010'     
        elif ac_value == 8 :
            return'1111111110110011'       
        elif ac_value == 9 :
            return'1111111110110100' 
        elif ac_value == 10 :
            return'1111111110110101'    
        else :
            return'hata kontrl et'

    elif zero_count == 8 :
        if ac_value == 1 :
            return'111111000'
        elif ac_value == 2 :
            return'111111111000000'
        elif ac_value == 3 :
            return'1111111110110110'    
        elif ac_value == 4 :
            return'1111111110110111'
        elif ac_value == 5 :
            return'1111111110111000'
        elif ac_value == 6 :
            return'1111111110111001' 
        elif ac_value == 7 :
            return'1111111110111010'     
        elif ac_value == 8 :
            return'1111111110111011'       
        elif ac_value == 9 :
            return'1111111110111100' 
        elif ac_value == 10 :
            return'1111111110111101'    
        else :
            return'hata kontrl et'
            
    elif zero_count == 9 :
        if ac_value == 1 :
            return'111111001'
        elif ac_value == 2 :
            return'1111111110111110'
        elif ac_value == 3 :
            return'1111111110111111'    
        elif ac_value == 4 :
            return'1111111111000000'
        elif ac_value == 5 :
            return'1111111111000001'
        elif ac_value == 6 :
            return'1111111111000010' 
        elif ac_value == 7 :
            return '1111111111000011'     
        elif ac_value == 8 :
            return'1111111111000100'       
        elif ac_value == 9 :
            return'1111111111000101' 
        elif ac_value == 10 :
            return'1111111111000110'    
        else :
            return'hata kontrl et'

    elif zero_count == 10 :
        if ac_value == 1 :
            return'111111010'
        elif ac_value == 2 :
            return'1111111111000111'
        elif ac_value == 3 :
            return'1111111111001000'    
        elif ac_value == 4 :
            return'1111111111001001'
        elif ac_value == 5 :
            return'1111111111001010'
        elif ac_value == 6 :
            return'1111111111001011' 
        elif ac_value == 7 :
            return'1111111111001100'     
        elif ac_value == 8 :
            return'1111111111001101'       
        elif ac_value == 9 :
            return'1111111111001110' 
        elif ac_value == 10 :
            return'1111111111001111'    
        else :
            return'hata kontrl et'
            
    elif zero_count == 11 :
        if ac_value == 1 :
            return'1111111001'
        elif ac_value == 2 :
            return'1111111111010000'
        elif ac_value == 3 :
            return'1111111111010001'    
        elif ac_value == 4 :
            return'1111111111010010'
        elif ac_value == 5 :
            return'1111111111010011'
        elif ac_value == 6 :
            return'1111111111010100' 
        elif ac_value == 7 :
            return'1111111111010101'     
        elif ac_value == 8 :
            return'1111111111010110'       
        elif ac_value == 9 :
            return'1111111111010111' 
        elif ac_value == 10 :
            return'1111111111011000'    
        else :
            return'hata kontrl et'
            
    elif zero_count == 12 :
        if ac_value == 1 :
            return'1111111010'
        elif ac_value == 2 :
            return'1111111111011001'
        elif ac_value == 3 :
            return'1111111111011010'    
        elif ac_value == 4 :
            return'1111111111011011'
        elif ac_value == 5 :
            return'1111111111011100'
        elif ac_value == 6 :
            return'1111111111011101' 
        elif ac_value == 7 :
            return'1111111111011110'     
        elif ac_value == 8 :
            return'1111111111011111'       
        elif ac_value == 9 :
            return'1111111111100000' 
        elif ac_value == 10 :
            return'1111111111100001'    
        else :
            return'hata kontrl et'

    elif zero_count == 13 :
        if ac_value == 1 :
            return'11111111000'
        elif ac_value == 2 :
            return'1111111111100010'
        elif ac_value == 3 :
            return'1111111111100011'    
        elif ac_value == 4 :
            return'1111111111100100'
        elif ac_value == 5 :
            return'1111111111100101'
        elif ac_value == 6 :
            return'1111111111100110' 
        elif ac_value == 7 :
            return'1111111111100111'     
        elif ac_value == 8 :
            return'1111111111101000'       
        elif ac_value == 9 :
            return'1111111111101001' 
        elif ac_value == 10 :
            return'1111111111101010'    
        else :
            return'hata kontrl et'

    elif zero_count == 14 :
        if ac_value == 1 :
            return'1111111111101011'
        elif ac_value == 2 :
            return'1111111111101100'
        elif ac_value == 3 :
            return'1111111111101101'    
        elif ac_value == 4 :
            return'1111111111101110'
        elif ac_value == 5 :
            return'1111111111101111'
        elif ac_value == 6 :
            return'1111111111110000' 
        elif ac_value == 7 :
            return'1111111111110001'     
        elif ac_value == 8 :
            return'1111111111110010'       
        elif ac_value == 9 :
            return'1111111111110011' 
        elif ac_value == 10 :
            return'1111111111110100'    
        else :
            return'hata kontrl et'

    elif zero_count == 15 :
        if ac_value == 1 :
            return'1111111111110101'
        elif ac_value == 2 :
            return'1111111111110110'
        elif ac_value == 3 :
            return'1111111111110111'    
        elif ac_value == 4 :
            return'1111111111111000'
        elif ac_value == 5 :
            return'1111111111111001'
        elif ac_value == 6 :
            return'1111111111111010' 
        elif ac_value == 7 :
            return'1111111111111011'     
        elif ac_value == 8 :
            return'1111111111111100'       
        elif ac_value == 9 :
            return'1111111111111101' 
        elif ac_value == 10 :
            return'1111111111111110'    
        else :
            return'hata kontrl et'
    elif zero_count == 16 :
        return 3547235

def run_length(zigzag_tarama):
    run_length=[]
    count=0
    dc=zigzag_tarama[0]
    boyut=size(dc)
    dc_deger=[boyut,dc]
    run_length.append(dc_deger)
    i=1
    while (i < 64):
        if zigzag_tarama[i]==0:
            count=count+1
            if count == 15:
                if i == 63:
                    run_length.append(['eob'])
                    count = 0
                    i=64
                else:
                    control = zigzag_tarama[i:64]
                    if all(x == 0 for x in control):
                        run_length.append(['eob'])
                        count = 0
                        i=64
                    else:
                        deneme= control[1]
                        if (deneme == 0):
                            run_length.append([16])
                            count=0
                            i = i + 1
            i = i + 1                
        elif (zigzag_tarama[i] != 0):
            a=count
            b=size(zigzag_tarama[i])
            c=zigzag_tarama[i]
            ac=[a,b,c]
            run_length.append(ac)
            count=0
            i = i + 1 
        if (i== 63):
            run_length.append(['eob'])
            count=0
            i= 64
    return run_length            
    
       
    



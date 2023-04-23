

file = open("D:/vivado/gorev3_test.txt","r")
for i in file:
    a = i

liste=[]    
for i in range(0,len(a),3):
    liste.append(a[i:i+3])
    
with open("D:/vivado/gorev3_cikti.txt","w") as f:
    for i in liste:
        f.write(i+"\n")
f.close()
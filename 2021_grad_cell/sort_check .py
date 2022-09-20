import cv2
import matplotlib.pyplot as plt


original = [302,423]
#plt.text(original[0], original[1], f"({original[0]},{original[1]})",fontsize=14)
total = [[302,423],[503,521],[694,768],[694,1023],[43,1003],[10,664]]
plt.figure(1)
for i in total:
    plt.plot([original[0],i[0]],[original[1],i[1]])
    plt.text(i[0], i[1], f"({i[0]},{i[1]})",fontsize=14)

plt.figure(2)
thi_side = []
plt.text(original[0], original[1], f"({original[0]},{original[1]})",fontsize=14)
for i in range(0,6):
    plt.text(total[i][0], total[i][1], f"({total[i][0]},{total[i][1]})",fontsize=14)
    if i == 0:
        temp = (((original[0] - total[i+1][0]) ** 2 + (original[1] - total[i+1][1]) ** 2) ** 0.5)
        thi_side.append(round(temp,3))
        plt.plot([original[0],total[i+1][0]],[original[1],total[i+1][1]])
        plt.text((original[0] + total[i+1][0])/2, (original[1] + total[i+1][1])/2, str(int(temp)),fontsize=14)
        reg = total[i+1]
        continue
    if i == 5:
        temp = (((total[0][0] - total[i][0]) ** 2 + (total[0][1] - total[i][1]) ** 2) ** 0.5)
        thi_side.append(round(temp,3))
        plt.plot([total[0][0],total[i][0]],[total[0][1],total[i][1]])
        plt.text((total[0][0] + total[i][0])/2, (total[0][1] + total[i][1])/2, str(int(temp)),fontsize=14)
        break
    temp = (((reg[0] - total[i+1][0]) ** 2 + (reg[1] - total[i+1][1]) ** 2) ** 0.5)
    thi_side.append(round(temp,3))
    plt.plot([reg[0],total[i+1][0]],[reg[1],total[i+1][1]])
    plt.text((reg[0] + total[i+1][0])/2, (reg[1] + total[i+1][1])/2, str(int(temp)),fontsize=14)
    reg = total[i+1]
    
print('第三邊長:',thi_side,'\n')
#R = [378,365,381,668,690,560]
# R = [118,294,559,763,567,252]
R = [574,501,420,354,298,468]
S = []

for i in range(0,6):
    if i < 5:
        s_temp = ((R[i]+ R[i+1] + thi_side[i])/2)
        S.append(round(s_temp,3))
    elif i == 5:
        s_temp = ((R[i]+ R[0] + thi_side[i])/2)
        S.append(round(s_temp,3))
print('各S的值:' , S,'\n')

heron1 = []
heron2 = []
for i in range(0,6):

        area_temp = (((S[i] - R[i]) * S[i]) ** 0.5)
        #print(S[i],R[i],thi_side[i])
        heron1.append(round(area_temp,1))


print('海龍第一部分:',heron1,'\n')

for i in range(0,6):
    if i < 5:
        heron_temp = ((S[i] - R[i+1]) * (S[i] - thi_side[i])) ** 0.5
        #print(S[i],R[i],thi_side[i])
        heron2.append(round(heron_temp,1))
    else:
        heron_temp = (((S[i] - R[0]) * (S[i] - thi_side[i])) ** 0.5)
        heron2.append(round(heron_temp,1))

print('海龍第二部分:',heron2,'\n')

area = []
total_area = 0
for i in range(0,6):
    ar = heron1[i] * heron2[i]
    total_area = total_area + ar
    print(total_area)
    area.append(round(ar))
print('各三角形面積:',area,'\n')
print('總面積:',(total_area))

area1 = 0
for i in range(0,6):
    if i < 5:
        area1 = (total[i][0]*total[i+1][1] - total[i+1][0]*total[i][1]) + area1
        print(area1)
    else:
        area1 = (total[i][0]*total[0][1] - total[0][0]*total[i][1]) + area1
        print(area1)
print(area1/2)
plt.show()




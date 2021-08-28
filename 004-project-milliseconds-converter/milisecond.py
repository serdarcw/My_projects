def calc_time(total_millisec):
    time_values=[3600000,60000,1000,1]
    i, B=0, []   # We will put time values in to  blank list
    while total_millisec>0:
        if total_millisec//time_values[i]>0:  #if there is 
            B.append(total_millisec//time_values[i]) 
        else:
            B.append(0)  # If there is no 
        total_millisec-=(total_millisec//time_values[i])*time_values[i]
        i+=1
    if B[0]!=0 or B[1]!=0 or B[2]!=0:
        print(((B[0]!=0)*(str(B[0])+' hour/s '))+((B[1]!=0)*(str(B[1])+' minute/s '))+((B[2]!=0)*(str(B[2])+' second/s ')))
    else:
        print('just'+' '+str(B[3])+' milisecond/s')

calc_time(555)
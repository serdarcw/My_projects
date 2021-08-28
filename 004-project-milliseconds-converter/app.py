from flask import Flask, render_template, request

app = Flask(__name__)

def calc_time(total_millisec):
    time_values=[3600000,60000,1000,1]
    i, B=0, []   # We will put time values in to    blank list
    while total_millisec>0:
        if total_millisec//time_values[i]>0:  #if there is 
            B.append(total_millisec//time_values[i]) 
        else:
            B.append(0)  # If there is no 
        total_millisec-=(total_millisec//time_values[i])*time_values[i]
        i+=1
    if B[0]!=0 or B[1]!=0 or B[2]!=0:
        return ((B[0]!=0)*(str(B[0])+' hour/s '))+((B[1]!=0)*(str(B[1])+' minute/s '))+((B[2]!=0)*(str(B[2])+' second/s '))
    else:
        return 'just'+' '+str(B[3])+' milisecond/s'

@app.route('/', methods = ['GET'])
def main_get():
    return render_template('index.html', developer_name = 'Serkan', not_valid = False)

@app.route('/', methods = ['POST'])
def main_post():
    alpha = request.form['number']
    if not alpha.isdecimal():
        return render_template('index.html', developer_name = 'Serkan', not_valid = True)
    number = int(alpha)
    if number < 1:
        return render_template('index.html', developer_name = 'Serkan', not_valid = True)
    return render_template('result.html', milliseconds = number, result = calc_time(number), developer_name = 'Serkan')

if __name__=='__main__':
    #app.run()
    #app.run(debug=True)
    app.run('0.0.0.0',port=80)






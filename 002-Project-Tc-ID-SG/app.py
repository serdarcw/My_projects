from flask import Flask, render_template, request

app = Flask(__name__)

def tckimlik(n):
    tc=[int(i) for i in str(n)]
    sum1=(sum(tc[0:9:2]))*7 
    mult=sum(tc[1:8:2])
    result1=sum1-mult
    if result1%10!=tc[9]:
        return 'not Valid'
    elif sum(tc[:10])%10!=tc[10]:
        return 'not Valid'
    else:
        return 'Valid'

@app.route('/', methods = ['GET'])
def main_get():
    return render_template('index.html', developer_name = 'Serkan', not_valid = False)


@app.route('/', methods=['POST'])
def TcKimlik():
    alpha = request.form['tcnumber']
    if not alpha.isdecimal():
        return render_template('index.html', developer_name = 'Serkan', not_valid = True)
    if len(alpha) != 11:
        return render_template('index.html', developer_name = 'Serkan', not_valid = True)
    if alpha[0]=='0':
        return render_template('index.html', developer_name = 'Serkan', not_valid = True)
    number = int(alpha)
    return render_template('result.html', tc_decimal = number, result = tckimlik(number), developer_name = 'Serkan')


if __name__ == '__main__':
    #app.run()
    #app.run(debug=True)
    app.run('0.0.0.0',port=80)
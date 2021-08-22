## Ansible Project Notes

## Ayağa kaldırılacak instance'ların özellikleri
1. 4 adet `Red Hat Enterprise Linux 8 (HVM), SSD Volume Type` t2.micro makine ayağa kaldırılacak
2. İsimleri
   a.  Control Node
    Name: ansible_control
    - 22 from anywhere

   b.  Nodejs
   Name: ansible_nodejs
    - 22 from anywhere
    - 5000 from anywhere

   b. PostgreSQL
    Name: ansible_postgresql
    - 22 from anywhere
    - 5432 from ansible_nodejs

   - ansible_react
    - 22 from anywhere
    - 80 from anywhere
    - 3000 from anywhere

Control Node oluşturulurken aşağıdaki Userdata kullabılabilir

```bash
#! /bin/bash

yum update -y
yum install python3 -y
pip3 install --user ansible
yum install git -y
```

### Initial Configurations

- Go to the control node
```bash
ssh -i <pem key> ec2-user@<Public IP or DNS>

```

- Create inventory and ansible.cfg file 

```bash
mkdir ansible
cd ansible
```

- Dikkat!!! ---> postgresql, nodejs ve react ec2-lar key:environment, value: development olarak taglenecek

- sonrasında `ansible.cfg` ve `inventory_aws_ec2.yml` file lar oluşturulacak. Dosya dizininde bu file'lar bulunabilir. 

- Dynamic inventor'nin kullanılabilmesi için iki şartın sağlanması gerekit
1. Control node'a EC2 full access IAM yetkisi verilmesi gerekir. İlgili IAM rolu oluşturalım ve control node' a ekleyelim

2. boto3 nin ec2-user kullanıcısı ile yüklenmesi gerekir
```bash
sudo pip3 install --user boto3
```

- create `ansible-Project` folder under home folder
```bash
mkdir ansible-Project
cd ansible-Project
```

- to-do app dosyasını github'dan buraya indireceğiz
```bash
git clone https://github.com/edwardBenedict/todo-app-pern.git
```

- Create `postgres`, `nodejs` and `react ` folders under `ansible-Project` folder
```bash
mkdir postgres
cd postgres

mkdir nodejs
cd nodejs

mkdir react
cd react
```

### CONFIGURATION OF POSTGRESQL WORKER NODE
While postgre container is created, we need to create `clarusdb` database and `todo` table into it. To do this, first we create our `init.sql` file. This file must be put under `docker-entrypoint-initdb.d/` file, while dockerfile is being written.  

Lets write init.sql file at first than write Dockerfile.
```bash
- vi init.sql
```sql
CREATE DATABASE clarustodo;

\c clarustodo;

CREATE TABLE todo(
    todo_id SERIAL PRIMARY KEY,
    description VARCHAR(255)
);
```

- Dockerfile
```Dockerfile
FROM postgres

RUN mkdir -p /tmp/psql_data/

COPY ./deneme/init.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
```

- After create `Dockerfile` and `init.sql` under `postgres`, go to `/home/ec2-user/ansible` folder and create playbook for `ansbile_postgre` node

- create `docker_postgre.yml`

- after control it, run this playbook
```bash
ansible-playbook docker_postgre.yml
```

- After finishing execute this playbook, please move it under `/home/ec2-user/ansible-Project/postgres` folder


<!-- Bu kısım postgre node da manuel olarak kontainer oluşumu gösterilmek istenirse yapılabilir

- pgadmin den oluşan database ve table gösterilebilir

- Imaj oluşturma
```bash
docker build -t serkangumus06/postgre .
```

- Container oluşturma
```bash
docker run --name serdar_postgre -e POSTGRES_PASSWORD=Pp123456789 -p 5432:5432 -d serkangumus06/postgre:latest
``` -->

### Frontend ve Backend de Node'ların hazırlanması

## CONFIGURATION OF NODEJS WORKER NODE

- Configure the settings of nodejs. to do this go under `/home/ec2-user/ansible-Project/todo-app-pern/server` and create `.env` file here

```bash
vi .env

SERVER_PORT=5000
DB_USER=postgres
DB_PASSWORD=Pp123456789
DB_NAME=clarustodo
DB_HOST=<postgre node's Internal IP>
DB_PORT=5432
```

- Go under `/home/ec2-user/ansible-Project/nodejs` folder and create `Dockerfile` for nodejs container

- After create `Dockerfile`  under `nodejs`, go to `/home/ec2-user/ansible` folder and create playbook for `ansible_nodejs` node

- create `docker_nodejs.yml`

- after control it, run this playbook
```bash
ansible-playbook docker_nodejs.yml
```


<!-- Bu kısım nodejs in kurulumunun teker teker anlatılmak istenmesi durumunda kullanılabilir. 

- Nodejs kurulumu

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node
node -e "console.log('Running Node.js ' + process.version)"
```
https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html

- Kurulduktan sonra edward hocamın repoyu react ve nodejs e indir. 
```bash
git clone https://github.com/edwardBenedict/todo-app-pern.git
```

Nodejs instance için
nodejs e gel ve server folder'ının altına

.env oluştur

SERVER_PORT=5000
DB_USER=postgres
DB_PASSWORD=Pp123456789
DB_NAME=clarustodo
DB_HOST=<postgre node's Internal IP>
DB_PORT=5432

- dependency’lerin server alt klasörünün içinde çalışması için

```bash
npm install
npm install -g --force nodemon
npm start
``` -->

- 5000 portundan deneyelim
http://<nodejs Public DNS>:5000/todos --> bu yapıldığında 
[] köşeli parantez görülecektir

- After finishing execute this playbook, please move it under `/home/ec2-user/ansible-Project/nodejs` folder

## CONFIGURATION OF REACT WORKER NODE

- Configure the settings of nodejs. to do this go under `/home/ec2-user/ansible-Project/todo-app-pern/client` and correct `.env` file here

```bash
vi .env

REACT_APP_BASE_URL=http://<Nodejs instance Public Ip ya da DNS>:5000/

```

- Go under `/home/ec2-user/ansible-Project/react` folder and create `Dockerfile` for nodejs container

- After create `Dockerfile`  under `react`, go to `/home/ec2-user/ansible` folder and create playbook for `ansible_react` node

- create `docker_nodejs.yml`

- after control it, run this playbook
```bash
ansible-playbook docker_nodejs.yml
```


<!-- Bu kısım manuel kurulumun gösterilmek istenmesi durumunda kullanılabilir

- React Node'un ayarlanması

- indirilen git repository de client klasörünün altına girelim

- .env file oluştur
REACT_APP_BASE_URL=http://<Nodejs instance Public Ip ya da DNS>:5000/

- dependency’lerin server alt klasörünün içinde çalışması için
```bash
npm install
npm install -g --force nodemon
npm start
``` -->



- <React Public IP:3000> ---> yayın buradan yapılıyor


### Second part of the Project - Combined Playbook

- we'll combine all these playbooks in one playbook. Create combined playbook using previous three playbooks and explain how to create this file with them

- run this combined playbook
```bash
ansible-playbook docker-project.yml
```

### Third part of the Project - Playbook with Roles

Please create 4 roles under `/home/ec2-user/ansible/roles` folder

ansible-galaxy init docker
ansible-galaxy init postgres
ansible-galaxy init nodejs
ansible-galaxy init react

- Copy whole file from A to B
```bash
cp -r /home/ec2-user/ansible-Project/todo-app-pern/server/ ./files/
```












Some Important Notes

------------------------------------

Bu ilk aşaması idi

Docker için role

https://galaxy.ansible.com/geerlingguy/docker

For gather_facts explanation :https://abhijeet-kamble619.medium.com/10-things-you-should-start-using-in-your-ansible-playbook-808daff76b65

--------------------------

1. Most of the modules and plugins in community.docker require the Docker SDK for Python. The SDK needs to be installed on the machines where the modules and plugins are executed, and for the Python version(s) with which the modules and plugins are executed.

You can install the Docker SDK for Python for Python 2.7 or Python 3 as follows:

```bash
pip install docker
```


Resources

1. https://faun.pub/launch-and-configure-docker-container-using-ansible-playbook-95607550623f


## AWS CLI comments

Create Security Group and Launch instance with userdate on CLI

CLI create security group and add ingress rule 

 aws ec2 create-security-group --group-name serdar_sec_group --description "Serdar's Sec Group to allow http and ssh from anywhere"
 
aws ec2 create-security-group --group-name serdar_sec_group --description "Serdars Sec Group to allow http and ssh from anywhere"

aws ec2 describe-security-groups --group-names serdar_sec_group\n

curl https://checkip.amazonaws.com

aws ec2 authorize-security-group-ingress --group-id sg-07d6dd9ab36fc758c --protocol tcp --port 22 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id sg-07d6dd9ab36fc758c --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id sg-07d6dd9ab36fc758c --protocol tcp --port 443 --cidr 0.0.0.0/0



To delete your sec-group

aws ec2 delete-security-group --group-id sg-903004f8


aws ec2 run-instances --image-id ami-0742b4e673072066f  --count 1 --instance-type t2.micro --key-name serdar --security-group-ids sg-07d6dd9ab36fc758c


aws ec2 run-instances --image-id ami-0742b4e673072066f --count 1 --instance-type t2.micro \
--key-name serdar --security-group-ids sg-07d6dd9ab36fc758c \
--user-data file://userdata.txt


To see user data on CLI
 aws ec2 describe-instance-attribute --instance-id i-08f3c75d227839fa4 --attribute userData --output text --query "UserData.Value" | base64 —decode

Querry

aws ec2 describe-instances --filters "Name=instance-type,Values=t2.micro" --query "Reservations[].Instances[].InstanceId”

Delete instance
aws ec2 terminate-instances --instance-ids i-08f3c75d227839fa4

Delete Security Group
aws ec2 delete-security-group --group-name serdar_sec_group
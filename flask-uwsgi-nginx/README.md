# centos

## install
```bash
$ yum install python-devel
$ pip install uwsgi flask
```

## configuration
* 1.创建一个flask项目
```bash
$ mkdir flask-uwsgi-nginx
```

* 2.创建一个flask启动文件
```bash
$ cd flask-uwsgi-nginx
$ cat > run.py << EOF
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "hello flask+uwsgi+nginx!"

if __name__ == "__main__":
    app.run(host='0.0.0.0')
EOF
```

* 3.测试uwsgi是否可用
```bash
$ uwsgi --socket 0.0.0.0:5000 --protocol=http -w run:app
$ curl localhost:5000
```

* 4.编写uwsgi配置文件: 在项目根路径创建文件`sample-flask.ini`
```ini
[uwsgi]
uid = root
gid = root
# 要启动的模块
module = run:app
master = true
# 启动3个子进程处理请求
processes = 3
# 项目的根目录，即 run.py 所在文件夹
chdir = /root/flask-uwsgi-nginx
# uwsgi 启动后所需要创建的文件，这个文件用来和 Nginx 通信，后面会在配置 Nginx 时用到，所以 chmod-socket = 660 是为了修改 .sock 文件权限来和 Nginx 通信
socket = /root/flask-uwsgi-nginx/simple-flask.sock
# 日志配置
daemonize = /tmp/simple-flask.log
chmod-socket = 660
# 自动移除unix Socket和pid文件当服务停止的时候
vacuum = true
```

* 5.启动uwsgi进程
```bash
$ uwsgi --ini /root/flask-uwsgi-nginx/simple-flask.ini
```

* 6.配置nginx: 创建文件`/etc/nginx/conf.d/simple-flask.conf`
```conf
upstream simple-flask {
    server unix:///root/flask-uwsgi-nginx/simple-flask.sock;
}

server {
    listen 5000;
    server_name localhost;
    access_log  /var/log/nginx/access-simple-flask.log  main;
    index index.html index.htm;
    charset utf-8;
    #client_max_body_size 75M;

    location / {
        uwsgi_pass simple-flask;
        include uwsgi_params;
    }
}

```

* 7.启动nginx
```bash
$ systemctl start nginx
```

* 8.测试
```bash
$ curl localhost:5000
```

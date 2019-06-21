#! /bin/bash
#
# --protocol 说明使用 http 协议
# -w 指明了要启动的模块, "run"就是项目启动文件"run.py"去掉扩展名，app是"run.py"文件中的变量"app"即Falsk实例
# 测试：curl 127.0.0.1:5000
uwsgi --socket 0.0.0.0:5000 --protocol=http -w run:app

# Copyright 2015 Oscar Cortez

FROM ubuntu:14.04

run apt-get update
run apt-get install -y build-essential git curl mercurial
run apt-get install -y python python-dev python-setuptools python-software-properties
run apt-get install -y nginx supervisor
run apt-get update
run apt-get install -y postgresql postgresql-contrib

# install pip
run easy_install pip

# install uwsgi now because it takes a little while
run pip install uwsgi

# install fabric
run pip install fabric

# intall virtualenv
run pip install virtualenv

# create a virtualenv replace te env_name
run mkvirtualenv docker

# install our code
add . /home/docker/code/

# setup all the configfiles
run echo "daemon off;" >> /etc/nginx/nginx.conf
run rm /etc/nginx/sites-enabled/default
run ln -s /home/docker/code/nginx-app.conf /etc/nginx/sites-enabled/
run ln -s /home/docker/code/supervisor-app.conf /etc/supervisor/conf.d/

expose 80
cmd ["supervisord", "-n"]

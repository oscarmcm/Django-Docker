# Copyright 2015 Oscar Cortez

FROM ubuntu

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Enable multiverse
RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list

# Insert bashrc
ADD bashrc /root/.bashrc

# Set HOME so bashrc is sourced
ENV HOME /root

# Set locale
# Note: preseeding debconf is 'better', but didn't want to install
# 'debconf-utils' just to do this in more steps.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Install base packages
run apt-get update
run apt-get upgrade -y
run apt-get update &&  apt-get install -y \
     make \
     automake \
     gcc \
     g++ \
     cpp \
     build-essential \
     libc6-dev \
     autoconf \
     pkg-config
     git \
     curl \
     mercurial \
     libxslt1-dev \
     libxml2-dev \
     python \
     python-dev \
     python-setuptools \ 
     python-software-properties \
     nginx \
     supervisor 

run apt-get update && apt-get install -y -q -f \
    postgresql-9.3 \
    postgresql-contrib-9.3 \
    postgresql-client-9.3 

# Install pip
run easy_install pip

# Install uwsgi now because it takes a little while
run pip install uwsgi

# Install fabric
run pip install fabric

# Intall virtualenv and wrapper
run pip install virtualenv
run pip install virtualenvwrapper

# Create a virtualenv replace te env_name
# run mkvirtualenv docker

# Install our code
# add . /home/docker/code/

# Setup all the configfiles NGINX
run echo "daemon off;" >> /etc/nginx/nginx.conf
run rm /etc/nginx/sites-enabled/default
run ln -s /home/docker/code/nginx-app.conf /etc/nginx/sites-enabled/
run ln -s /home/docker/code/supervisor-app.conf /etc/supervisor/conf.d/

# Setup all the configfiles Postgre
ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.3/main/*.conf
# ADD run /usr/local/bin/run
# RUN chmod +x /usr/local/bin/run

VOLUME ["/var/lib/postgresql"]

# Expose ports private only
EXPOSE 5432 
# CMD ["/usr/local/bin/run"]

EXPOSE 80
CMD ["supervisord", "-n"]

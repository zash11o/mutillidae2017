FROM docker.io/alpine:latest
MAINTAINER zash11o (@zash.shibainu)

RUN \
  # install/update
      apk update && apk upgrade \
  &&  apk add unzip \
              wget \
              apache2 \
              apache2-ssl \
              php7 \
              php7-apache2 \
              php7-session \
              php7-simplexml \
              php7-mbstring \
              php7-mysqli \
              php7-curl \
              php7-xml \
              php7-dom \
              php7-json \
              mariadb \
              mariadb-client \
  &&  rm -rf /var/lib/apt/lists/* \
  
  # Deploy Mutillidae
  &&  wget -O /mutillidae.zip --no-check-certificate \
            https://sourceforge.net/projects/mutillidae/files/latest/download \
  &&  unzip /mutillidae.zip \
  &&  rm -f /mutillidae.zip \
  
  # set apache2/mariadb 
  &&  mkdir -p /run/apache2 \
  &&  chown -R apache:apache /mutillidae /run/apache2 \
  &&  mkdir -p /run/mysqld \
  &&  chown -R mysql:mysql /run/mysqld /var/lib/mysql \
  # Configure apache2
  &&  sed -i 's#AllowOverride None#AllowOverride All#' /etc/apache2/httpd.conf  \
  &&  sed -i 's#ServerName www.example.com:80#\nServerName localhost:80#' /etc/apache2/httpd.conf \
  &&  sed -i 's#^DocumentRoot ".*#DocumentRoot "/"#g' /etc/apache2/httpd.conf \
  &&  sed -i 's#/var/www/localhost/htdocs#/#g' /etc/apache2/httpd.conf \
  &&  touch /var/log/apache2/access.log \
  # Configure MariaDB
  &&  mysql_install_db --user=mysql --verbose=1 --basedir=/usr --datadir=/var/lib/mysql --rpm > /dev/null \
  
  
  #start.sh
  &&  echo "#!/bin/sh" > /start.sh \
  &&  echo "httpd -k start" >> /start.sh \
  &&  echo "nohup mysqld --skip-grant-tables --bind-address 0.0.0.0 --user mysql > /dev/null 2>&1 &" >> /start.sh \
  &&  echo "sleep 3 && mysql -uroot -e \"create database db;\"" >> /start.sh \
  #&&  echo "tail -f /var/log/apache2/access.log" >> /start.sh \
  
  &&  chmod 644 /var/log/apache2/access.log \
  &&  chmod u+x /start.sh

EXPOSE 80 3306

CMD ["/start.sh"]

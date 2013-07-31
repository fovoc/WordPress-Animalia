###----------------------------------------###
###  EDIT OPTIONS BELOW
###----------------------------------------###

# Enter your site's domain below.
_ROOT_DOMAIN="domain.com"

# The MySQL ROOT password.
_MYSQL_ROOT_PASSWORD="RANDOM-PASSWORD-HERE"

# Use _NGINX_VRSION = "development" below 
# to use the latest, develoment version
_NGINX_VERSION="stable"

# Enter the number of CPUs that your VPS has.
_CPUS_NUMBER="1"

###----------------------------------------###
###  STOP EDITING,
###  DO NOT EDIT BELOW THIS LINE!
###----------------------------------------###

###----------------------------------------###
###  Update and upgrade the OS
###----------------------------------------###

apt-get install sudo
sudo apt-get update
sudo apt-get upgrade --force-yes --quiet --yes

# Install git
sudo apt-get install git --force-yes --quiet --yes

###----------------------------------------###
###  Install MariaDB and set root password
###----------------------------------------###

sudo apt-get install software-properties-common --force-yes --quiet --yes
sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
sudo add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu raring main'
sudo apt-get update
sudo apt-get install mariadb-server --force-yes --quiet --yes

sudo service mysql stop
echo "'UPDATE mysql.user SET Password=PASSWORD('$_MYSQL_ROOT_PASSWORD') WHERE User='root';'" > rootpass.txt
echo "FLUSH PRIVILEGES;'" >> rootpass.txt
sudo mysqld_safe --init-file=rootpass.txt &
sudo service mysql restart
sudo rm rootpass.txt

###----------------------------------------###
###  Apply MySQL config customizations
###----------------------------------------###

cd ~
sudo rm custom.cnf
wget https://raw.github.com/aristath/WordPress-Animalia/master/mysql/custom.cnf
sudo mv custom.cnf /etc/mysql/conf.d/custom.cnf
sudo service mysql restart

###----------------------------------------###
###  Install Nginx
###----------------------------------------###

sudo nginx=$_NGINX_VERSION
sudo add-apt-repository ppa:nginx/$nginx
sudo apt-get update
sudo apt-get install nginx --force-yes --quiet --yes

###----------------------------------------###
###  Install PHP-FPM
###----------------------------------------###

sudo add-apt-repository ppa:ondrej/php5 --yes
sudo apt-get update
sudo apt-get install php5-common php5-mysql php5-xmlrpc php5-cgi php5-curl php5-gd php5-cli php5-fpm php-apc php5-dev php5-mcrypt --force-yes --quiet --yes

###----------------------------------------###
###  Configure Nginx
###----------------------------------------###

service nginx stop

cd ~
wget https://raw.github.com/aristath/WordPress-Animalia/master/nginx/nginx.conf
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
sudo mv nginx.conf /etc/nginx/nginx.conf
sed -i "s/WORKER_PROCESSES/$_CPUS_NUMBER/g" /etc/nginx/nginx.conf

wget https://raw.github.com/aristath/WordPress-Animalia/master/nginx/wordpress.conf
sudo mv /etc/nginx/conf.d/wordpress.conf /etc/nginx/conf.d/wordpress.conf.old
sudo rm /etc/nginx/conf.d/wordpress.conf
sudo mv wordpress.conf /etc/nginx/conf.d/wordpress.conf

wget https://raw.github.com/aristath/WordPress-Animalia/master/nginx/wordpress-mu.conf
sudo mv /etc/nginx/conf.d/wordpress-mu.conf /etc/nginx/conf.d/wordpress-mu.conf.old
sudo rm /etc/nginx/conf.d/wordpress-mu.conf
sudo mv wordpress-mu.conf /etc/nginx/conf.d/wordpress-mu.conf
sed -i "s/WPDOMAIN/$_ROOT_DOMAIN/g" /etc/nginx/conf.d/wordpress-mu.conf

wget https://raw.github.com/aristath/WordPress-Animalia/master/nginx/restrictions.conf
sudo mv /etc/nginx/conf.d/restrictions.conf /etc/nginx/conf.d/restrictions.conf.old
sudo rm /etc/nginx/conf.d/restrictions.conf
sudo mv restrictions.conf /etc/nginx/conf.d/restrictions.conf

sudo mkdir /var/www
sudo chown -R www-data:www-data /var/www

###----------------------------------------###
###  Install WP-CLI
###----------------------------------------###

curl http://wp-cli.org/installer.sh > installer.sh
sudo INSTALL_DIR='/usr/share/wp-cli' bash installer.sh
sudo ln -s /usr/share/wp-cli/bin/wp /usr/bin/wp

###----------------------------------------###
###  Create Database for WordPress,
###  assign a user to that database
###  and create a password for that user.
###----------------------------------------###

_DB_NAME=$(perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 0..pop' 8)

_DB_USER=$(perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 0..pop' 8)

_DB_PASS=$(perl -le 'print map { (a..z,A..Z,0..9)[rand 62] } 0..pop' 8)

echo "CREATE USER 'DB_USER'@'localhost' IDENTIFIED BY 'DB_PASS';" > userdb.sql
echo "GRANT ALL PRIVILEGES ON * . * TO 'DB_USER'@'localhost';" >> userdb.sql
echo "FLUSH PRIVILEGES;" >> userdb.sql
sed -i "s/DB_USER/$_DB_USER/g" userdb.sql
sed -i "s/DB_PASS/$_DB_PASS/g" userdb.sql

mysql -h "localhost" -u root "$_MYSQL_ROOT_PASSWORD" "$_DB_NAME" < "userdb.sql"

###----------------------------------------###
###  Download and extract WordPress
###----------------------------------------###

cd /var/www
wget -O wordpress.tar.gz http://wordpress.org/latest.tar.gz
tar -zxvf wordpress.tar.gz
chown -R www-data:www-data /var/www/wordpress
sudo rm wordpress.tar.gz
sudo mv wordpress $_ROOT_DOMAIN

###----------------------------------------###
###  Configure Nginx for specific domain
###----------------------------------------###

cd ~
wget https://raw.github.com/aristath/WordPress-Animalia/master/nginx/domain.conf
sudo mv /etc/nginx/sites-available/$_ROOT_DOMAIN.conf /etc/nginx/sites-available/$_ROOT_DOMAIN.conf.old
sudo mv domain.conf /etc/nginx/sites-available/$_ROOT_DOMAIN.conf
sed -i "s/WPDOMAIN/$_ROOT_DOMAIN/g" /etc/nginx/sites-available/$_ROOT_DOMAIN.conf

cd /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/$_ROOT_DOMAIN.conf
touch /var/www/$_ROOT_DOMAIN/nginx.conf

###----------------------------------------###
###  Fix Permissions on files
###----------------------------------------###

WP_OWNER=www-data # <-- wordpress owner
WP_GROUP=www-data # <-- wordpress group
WP_ROOT=/var/www/$_ROOT_DOMAIN # <-- wordpress root directory
WS_GROUP=www-data # <-- webserver group
 
# reset to safe defaults
find ${WP_ROOT} -exec chown ${WP_OWNER}:${WP_GROUP} {} \;
find ${WP_ROOT} -type d -exec chmod 755 {} \;
find ${WP_ROOT} -type f -exec chmod 644 {} \;
 
# allow wordpress to manage wp-config.php (but prevent world access)
chgrp ${WS_GROUP} ${WP_ROOT}/wp-config.php
chmod 660 ${WP_ROOT}/wp-config.php
 
# allow wordpress to manage wp-content
find ${WP_ROOT}/wp-content -exec chgrp ${WS_GROUP} {} \;
find ${WP_ROOT}/wp-content -type d -exec chmod 775 {} \;
find ${WP_ROOT}/wp-content -type f -exec chmod 664 {} \;

###----------------------------------------###
###  Restart all related services
###----------------------------------------###

sudo service mysql stop
sudo service mysql start

sudo service php5-fpm stop
sudo service php5-fpm start

sudo service nginx stop
sudo service nginx start

cd /var/www/$_ROOT_DOMAIN
wp core config --dbname=$_DB_NAME --dbuser=$_DB_USER --dbpass=$_DB_PASS

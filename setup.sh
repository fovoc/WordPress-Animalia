###----------------------------------------###
###  EDIT OPTIONS BELOW
###----------------------------------------###

# Enter your site's domain below.
_ROOT_DOMAIN = "domain.com"

# The MySQL ROOT password.
_MYSQL_ROOT_PASSWORD = "RANDOM-PASSWORD-HERE"

# Use _NGINX_VRSION = "development" below 
# to use the latest, develoment version
_NGINX_VERSION = "stable"

# Enter the number of CPUs that your VPS has.
_CPUS_NUMBER = "1"

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
sed -i 's/WORKER_PROCESSES/$_CPUS_NUMBER/g' /etc/nginx/nginx.conf

wget https://raw.github.com/aristath/WordPress-Animalia/master/nginx/wordpress.conf
sudo mv /etc/nginx/conf.d/wordpress.conf /etc/nginx/conf.d/wordpress.conf.old
sudo rm /etc/nginx/conf.d/wordpress.conf
sudo mv wordpress.conf /etc/nginx/conf.d/wordpress.conf

wget https://raw.github.com/aristath/WordPress-Animalia/master/nginx/wordpress-mu.conf
sudo mv /etc/nginx/conf.d/wordpress-mu.conf /etc/nginx/conf.d/wordpress-mu.conf.old
sudo rm /etc/nginx/conf.d/wordpress-mu.conf
sudo mv wordpress-mu.conf /etc/nginx/conf.d/wordpress-mu.conf

wget https://raw.github.com/aristath/WordPress-Animalia/master/nginx/restrictions.conf
sudo mv /etc/nginx/conf.d/restrictions.conf /etc/nginx/conf.d/restrictions.conf.old
sudo rm /etc/nginx/conf.d/restrictions.conf
sudo mv restrictions.conf /etc/nginx/conf.d/restrictions.conf

sudo mkdir /var/www
sudo chown -R www-data:www-data /var/www

service nginx start

###----------------------------------------###
###  Install WP-CLI
###----------------------------------------###

curl http://wp-cli.org/installer.sh > installer.sh
sudo INSTALL_DIR='/usr/share/wp-cli' bash installer.sh
sudo ln -s /usr/share/wp-cli/bin/wp /usr/bin/wp

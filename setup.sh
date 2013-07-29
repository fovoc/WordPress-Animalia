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

###----------------------------------------###
###  EDIT OPTIONS BELOW
###----------------------------------------###

_MYSQL_ROOT_PASSWORD = "RANDOM-PASSWORD-HERE"
_ROOT_DOMAIN = "domain.com"

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
###  Install & Customize MariaDB
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

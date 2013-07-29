###----------------------------------------###
###  EDIT OPTIONS BELOW
###----------------------------------------###

_MYSQL_ROOT_PASSWORD = "RANDOM-PASSWORD-HERE"

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
sudo apt-get install mysql-server --force-yes --quiet --yes

###----------------------------------------###
###  Customize the my.cnf file
###----------------------------------------###

sudo rm /etc/mysql/my.cnf
sudo wget https://github.com/aristath/WordPress-Animalia/blob/master/mysql/my.cnf /etc/mysql/my.cnf

###----------------------------------------###
###  Restart the MySQL Server
###----------------------------------------###

sudo service mysql restart


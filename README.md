WordPress-Animalia
==================

This script will automatically setup your VPS with the following:
* MariaDB
* NGINX server
* PHP-FPM

On top of that, it will automatically config most aspects of your server for optimal performance with WordPress.

Installation:
=============

This must be run on a fresh Ubuntu server, using a root account:

`wget -q https://raw.github.com/aristath/WordPress-Animalia/master/setup.sh && nano setup.sh`

This will download the file and open up an editing screen.
If you see an error saying that nano is missing, run the following command:

`apt-get install nano`

`nano setup.sh`

On that editing screen you will have to edit the following options:
* Domain name (enter it like domain.com, NOT www.domain.com or http://domain.com, http://www.domain.com. JUST the domain like domain.com).
* a password that you want your root user to use for MariaDB. This should be a secure password so please make sure it's not something easy. During the installation process you might be asked to enter it again. SImply enter it again and press enter.
* Number of CPUs that your VPS has

Once you edit the options and you make sure they are right, press `Ctrl-X` on your keyboard to close the editing program.
You will be asked if you want to save the changes. PRESS Y.

Now, all you have to do is run this command:

`bash setup.sh`

and the installation script will do the rest for you.

If you want to contribute to the creation and improvement of this script then please feel free to fork it and push any pull requests you wish for consideration.

Have fun!

Aristeides Stathopoulos.

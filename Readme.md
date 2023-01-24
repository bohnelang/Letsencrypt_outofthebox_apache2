
#Lets encrypt - one script to install all


##Howto us this:
1) mkdir /etc/apache2/letsencrypt
2) cd /etc/apache2/letsencrypt
3) Copy this script to this dir
4) chmod 755 install_all.sh
5) ./install_all.sh
6) Do install certs, test it and enable periodical renewing of the certs.


You need to edit this part:

## Here this script is
WPATH=/etc/apache2/letsencrypt

## PAth of your document-root directory
WWW=/var/www/html/

## Your server name
SERVER=www.foo.foo

## Maybe an email
EMAIL=""

## Group of your Apache2
WWW_GRP=www-data

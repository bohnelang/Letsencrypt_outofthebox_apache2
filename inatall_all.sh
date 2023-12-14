#!/bin/bash

# Config this part for your system:

# Here this script is
WPATH=/etc/apache2/letsencrypt

# PAth of your document-root directory
WWW=/var/www/html/

# Your server name
SERVER=www.foo.foo

# Maybe an email
EMAIL=""

# Group of your Apache2
WWW_GRP=www-data

###########################################################

if ! test -e $WWW/.well-known
then
        mkdir $WWW/.well-known
        chown $WWW_GRP:$WWW_GRP  $WWW/.well-known
fi

if ! test -e $HOME/.rnd
then
        dd if=/dev/urandom of=$HOME/.rnd  bs=512 count=1
fi

cd $WPATH

if ! test -e work
then
        mkdir work
fi

if ! test -e zertifikate
then
        mkdir zertifikate
fi

if ! test -e logs
then
        mkdir logs
fi


if ! test -e getssl
then
        curl --silent https://raw.githubusercontent.com/srvrco/getssl/latest/getssl > getssl
        chmod 700 getssl
        ./getssl --upgrade 2> /dev/null > /dev/null
fi

if ! test -e work/$SERVER
then
        mkdir work/$SERVER
fi

if ! test -e work/$SERVER/getssl.cfg
then


cat > work/$SERVER/getssl.cfg <<_EOF_
# vim: filetype=sh
#
# This file is read second (and per domain if running with the -a option)
# and overwrites any settings from the first file
#
# Uncomment and modify any variables you need
# see https://github.com/srvrco/getssl/wiki/Config-variables for details
# see https://github.com/srvrco/getssl/wiki/Example-config-files for example configs
ACCOUNT_EMAIL="$EMAIL"

# The staging server is best for testing
#CA="https://acme-staging-v02.api.letsencrypt.org"
# This server issues full certificates, however has rate limits
CA="https://acme-v02.api.letsencrypt.org"

PRIVATE_KEY_ALG="rsa"

SANS=""

ACL=("$WWW/.well-known/acme-challenge")

USE_SINGLE_ACL="true"

#PREFERRED_CHAIN="\(STAGING\) Pretend Pear X1"

FULL_CHAIN_INCLUDE_ROOT="true"

CA_CERT_LOCATION="$WPATH/zertifikate/ca_certificate.crt" # this is CA cert
DOMAIN_CHAIN_LOCATION="$WPATH/zertifikate/fullchain.txt" # this is the domain cert and CA cert
DOMAIN_CERT_LOCATION="$WPATH/zertifikate/$SERVER.csr" # this is domain cert
DOMAIN_KEY_LOCATION="$WPATH/zertifikate/$SERVER.key" # this is domain key
DOMAIN_PEM_LOCATION="$WPATH/zertifikate/$SERVER.pem" # this is the domain key, domain cert and CA cert

#RELOAD_CMD="service apache2 reload"
RELOAD_CMD="/usr/sbin/apachectl restart"

#PREVENT_NON_INTERACTIVE_RENEWAL="true"

#SERVER_TYPE="https"
#CHECK_REMOTE="true"
#CHECK_REMOTE_WAIT="5" # wait 2 seconds before checking the remote server

_EOF_

fi



./getssl -w work  $SERVER >logs/out.log 2> logs/err.log


if   test -e  work/$SERVER/getssl.cfg
then
        if ! test -e getssl.cfg
        then
                ln -s work/$SERVER/getssl.cfg getssl.cfg
        fi
fi

if test -e zertifikate/fullchain.txt
then
        if test -e zertifikate/$SERVER.csr
        then
                cat  zertifikate/fullchain.txt zertifikate/${SERVER}.csr > zertifikate/${SERVER}-full.csr
        fi
fi

if ! test -e zertifikate/${SERVER}-full.csr
then
        echo "Cannot create zertifikate/${SERVER}-full.csr"
        exit
fi


####

if ! test -e cron.sh
then
cat > cron.sh <<_EOF_
#!/bin/bash

WPATH=$WPATH

SERVER=$SERVER


###########################################################

cd \$WPATH

./getssl -w work  \$SERVER>  logs/out.log 2> logs/err.log

if test -e zertifikate/fullchain.txt
then
        if test -e zertifikate/\$SERVER.csr
        then
                cat  zertifikate/fullchain.txt zertifikate/\${SERVER}.csr > zertifikate/\${SERVER}-full.csr
        else
                echo "ERROR: Cannot create zertifikate/\${SERVER}-full.csr" >> logs/err.log
                exit
        fi
fi

_EOF_

chmod 700 cron.sh

fi

#######################################################

cat > memo.txt <<_EOF_
echo "Please check  work/$SERVER/getssl.cfg for finetuning..."

echo
echo "Add to your Apache2 config this in SSL-Part (sites-enabled)"
echo "SSLCertificateFile            $WPATH/zertifikate/${SERVER}-full.csr"
echo "SSLCertificateKeyFile         $WPATH/zertifikate/${SERVER}.key"

echo
echo "Append to crontab this line"
echo "0 3 1 * * $WPATH/cron.sh"

echo
_EOF_

cat memo.txt

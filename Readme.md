
# Lets encrypt - one script to install all


## Howto us this:
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


# Some hints for Apache2 configuration
Test your server certificate with: https://www.ssllabs.com/ssltest/ after installation 

```
Some hints for configuration: The letsencrypt challange is normally done on port 80 by http:// - thus you need both ports open. 

# The 
Listen 80
<VirtualHost *:80>
        ServerAdmin     edv-service@your-domain
        ServerName      your-server-name

        DocumentRoot /var/www/html

        ErrorLog ${APACHE_LOG_DIR}/error80.log
        CustomLog ${APACHE_LOG_DIR}/access80.log combined 
        
        RewriteEngine On

        # Let's Encrypt Challange
        RewriteRule     ^/\.well-known/                          -                       [L]

	# Redirect all other requests to https...
        RewriteRule     ^(.*)$                          https://%{SERVER_NAME}%{REQUEST_URI}    [NE,R,L]
</VirtualHost>



<IfModule mod_ssl.c>
Listen 443
#SSLRandomSeed startup file:/dev/urandom 512
#SSLRandomSeed connect file:/dev/urandom 512

SSLRandomSeed startup builtin
SSLRandomSeed connect builtin


SSLPassPhraseDialog     builtin
SSLSessionCache         "shmcb:/var/run/ssl_scache(5120000)"
SSLSessionCacheTimeout  300

AddType application/x-x509-ca-cert .crt
AddType application/x-pkcs7-crl    .crl

ServerTokens Major

<VirtualHost _default_:443>
	ServerAdmin edv-service@your-domain
	ServerName your-servername
                
        DocumentRoot /var/www/html

	RewriteEngine On
	SSLEngine on

	Options -Indexes
	  
	#LogLevel info ssl:warn
              
	CustomLog ${APACHE_LOG_DIR}/access_443.log combined            
	ErrorLog ${APACHE_LOG_DIR}/error_443.log
  
	SSLCertificateFile              "zertifikate/letsencrypt/zertifikate/your-servername-full.csr"
	SSLCertificateKeyFile           "zertifikate/letsencrypt/zertifikate/your-servername.key"

	SSLHonorCipherOrder on
	SSLProtocol all -TLSv1.1 -TLSv1 -SSLv2 -SSLv3
	SSLCipherSuite HIGH:MEDIUM:!LOW:!ADH:!EXP:!NULL:!aNULL:!MD5:!RC4
          
	<FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
	</FilesMatch>

	<Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
	</Directory>

	BrowserMatch "MSIE [2-6]" \
                                nokeepalive ssl-unclean-shutdown \
                                downgrade-1.0 force-response-1.0            

	# Lokale Definitionen
	#Include sites-global-defines/expires.conf

	# ... your configuration ...

</VirtualHost>
</IfModule>
```

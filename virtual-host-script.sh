#!/bin/bash

name=$1
WEB_ROOT_DIR=$2

# Create a log directory
logsDirMain='/var/log/apache2/'
logsDir=$logsDirMain$name
mkdir $logsDir

email=${3-'webmaster@localhost'}
sitesAvailable='/etc/apache2/sites-available/'
sitesAvailabledomain=$sitesAvailable$name.conf
echo "Creating a vhost for $sitesAvailabledomain with a webroot $WEB_ROOT_DIR"

if [ ! -f "$sitesAvailabledomain" ]; then
  # Create Host file
  echo "
      <VirtualHost *:80>
        ServerName $name
        ServerAdmin $email
        DocumentRoot $WEB_ROOT_DIR
        ErrorLog $logsDir/error.log
        CustomLog $logsDir/access.log combined
        <Directory $WEB_ROOT_DIR>
          # Require all granted
          Options Indexes FollowSymLinks MultiViews
          AllowOverride All
          allow from all
        </Directory>
      </VirtualHost>" > $sitesAvailabledomain
  echo -e $"\nNew Virtual Host Created\n"

  sed -i "1s/^/127.0.0.1 $name\n/" /etc/hosts

  a2ensite $name
  #service apache2 reload
  service apache2 restart

  echo "Done, please browse to http://$name to check!"

else
    echo "$name already created. please browse to http://$name to check!"
fi

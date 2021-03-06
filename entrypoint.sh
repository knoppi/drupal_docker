#!/bin/sh

set -x

# check if drupal has already been installed
if [ ! -e /var/www/html/sites/default/settings.php ]
then

# wait - sql might still be spawning
sleep 40

# populate themes folder
cp -R /bak/themes/* /var/www/html/themes/

# create default site with empty settings
mkdir /var/www/html/sites/default
cp /bak/sites/default/default.settings.php /var/www/html/sites/default/default.settings.php

pear install Console_Table

/opt/drush/drush -y si \
  --db-url="mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}/${MYSQL_DATABASE}" \
  --account-name="admin" \
  --account-pass="${LDAP_PASSWD}" \
  --site-name="${SITE_NAME}" \
  -v --debug
  #--locale="de" \

chmod -R a+w /var/www/html/sites/default/files

# this setup is meant to reside behind a reverse proxy, so unless explicitely turned off
# this script tweaks the drupal settings for that case
if [ -z "$NO_PROXY" ]
then
  NEW_VALUE="\$conf['reverse_proxy'] = 1;\n\$_SERVER['HTTPS'] = 'on';"
  sed -i "s/# \$conf\['reverse_proxy'\].*$/${NEW_VALUE}/" /var/www/html/sites/default/settings.php
fi


# setup the LDAP server
/opt/drush/drush -y pm-enable ldap_servers ldap_user ldap_authentication

# setup of the smtp configuration
# at a later point this will be more modular if
# you want to use something else like an
# individual mailer container
/opt/drush/drush -y pm-enable smtp

/opt/drush/drush vset --exact smtp_allowhtml 0
/opt/drush/drush vset --exact smtp_client_helo ""
/opt/drush/drush vset --exact smtp_debugging "2"
/opt/drush/drush vset --exact smtp_deliver "1"
/opt/drush/drush vset --exact smtp_hostbackup ""
/opt/drush/drush vset --exact smtp_on "1"
/opt/drush/drush vset --exact smtp_previous_mail_system "DefaultMailSystem"
/opt/drush/drush vset --exact smtp_protocol "standard"
/opt/drush/drush vset --exact smtp_queue 1
/opt/drush/drush vset --exact smtp_queue_fail 1
/opt/drush/drush vset --exact smtp_reroute_address ""
/opt/drush/drush vset --exact smtp_protocol "ssl"

/opt/drush/drush vset --exact smtp_client_hostname $smtp_client_hostname
/opt/drush/drush vset --exact smtp_from            $smtp_from
/opt/drush/drush vset --exact smtp_fromname        $smtp_fromname 
/opt/drush/drush vset --exact smtp_host            $smtp_host 
/opt/drush/drush vset --exact smtp_username        $smtp_username 
/opt/drush/drush vset --exact smtp_password        $smtp_password 
/opt/drush/drush vset --exact smtp_port            $smtp_port 

echo "\$conf['drupal_http_request_fails'] = FALSE;" >> /var/www/html/sites/default/settings.php
echo "\$conf['mail_system']['default-system'] = 'SmtpMailSystem';" >> /var/www/html/sites/default/settings.php

fi

# call the entrypoint of the base-baseimage (php:7.1-apache) manually
docker-php-entrypoint apache2-foreground

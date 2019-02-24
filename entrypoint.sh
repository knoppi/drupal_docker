#!/bin/sh

set -x

# check if drupal has already been installed
if [ ! -e /var/www/html/sites/default/settings.php ]
then

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
  -v --debug
  #--locale="de" \

chmod -R a+w /var/www/html/sites/default/files

# setup the LDAP server
/opt/drush/drush -y pm-enable ldap_servers ldap_user

# setup of the smtp configuration still included
# at a later point this will be more modular if
# you want to use something else like an
# individual mailer container
#/opt/drush/drush -y pm-enable smtp
#
#/opt/drush/rush vset --exact smtp_allowhtml 0
#/opt/drush/rush vset --exact smtp_client_helo ""
#/opt/drush/rush vset --exact smtp_debugging "2"
#/opt/drush/rush vset --exact smtp_deliver "1"
#/opt/drush/rush vset --exact smtp_hostbackup ""
#/opt/drush/rush vset --exact smtp_on "1"
#/opt/drush/rush vset --exact smtp_previous_mail_system "DefaultMailSystem"
#/opt/drush/rush vset --exact smtp_protocol "standard"
#/opt/drush/rush vset --exact smtp_queue 1
#/opt/drush/rush vset --exact smtp_queue_fail 1
#/opt/drush/rush vset --exact smtp_reroute_address ""
#/opt/drush/rush vset --exact smtp_protocol "ssl"
#
#/opt/drush/drush vset --exact smtp_client_hostname $smtp_client_hostname
#/opt/drush/drush vset --exact smtp_from            $smtp_from
#/opt/drush/drush vset --exact smtp_fromname        $smtp_fromname 
#/opt/drush/drush vset --exact smtp_host            $smtp_host 
#/opt/drush/drush vset --exact smtp_username        $smtp_username 
#/opt/drush/drush vset --exact smtp_password        $smtp_password 
#/opt/drush/drush vset --exact smtp_port            $smtp_port 
#
#/opt/drush/echo "\$conf['drupal_http_request_fails'] = FALSE;" >> /drupal_data/settings.php
#/opt/drush/echo "\$conf['mail_system']['default-system'] = 'SmtpMailSystem';" >> /drupal_data/settings.php

fi

# call the entrypoint of the base-baseimage (php:7.1-apache) manually
docker-php-entrypoint apache2-foreground

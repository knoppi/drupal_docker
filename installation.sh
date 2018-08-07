#!/bin/sh

set -x

if [ ! -e /drupal_data/installed ]
then

cp /var/www/html/sites/old_default/default.settings.php /drupal_data/default.settings.php
drush -y si standard --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}/${MYSQL_DATABASE} --account-name=admin --account-pass=${LDAP_PASSWD} -v --locale=de
chmod a+w /drupal_data/files

# setup the LDAP server
drush -y pm-enable ldap_servers ldap_user

# setup of the smtp configuration still included
# at a later point this will be more modular if
# you want to use something else like an
# individual mailer container
drush -y pm-enable smtp

drush vset --exact smtp_allowhtml 0
drush vset --exact smtp_client_helo ""
drush vset --exact smtp_debugging "2"
drush vset --exact smtp_deliver "1"
drush vset --exact smtp_hostbackup ""
drush vset --exact smtp_on "1"
drush vset --exact smtp_previous_mail_system "DefaultMailSystem"
drush vset --exact smtp_protocol "standard"
drush vset --exact smtp_queue 1
drush vset --exact smtp_queue_fail 1
drush vset --exact smtp_reroute_address ""
drush vset --exact smtp_protocol "ssl"

drush vset --exact smtp_client_hostname $smtp_client_hostname
drush vset --exact smtp_from            $smtp_from
drush vset --exact smtp_fromname        $smtp_fromname 
drush vset --exact smtp_host            $smtp_host 
drush vset --exact smtp_username        $smtp_username 
drush vset --exact smtp_password        $smtp_password 
drush vset --exact smtp_port            $smtp_port 

date > /drupal_data/installed

echo "\$conf['drupal_http_request_fails'] = FALSE;" >> /drupal_data/settings.php
echo "\$conf['mail_system']['default-system'] = 'SmtpMailSystem';" >> /drupal_data/settings.php

fi

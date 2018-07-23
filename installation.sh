#!/bin/sh

cp /var/www/html/sites/old_default/default.settings.php /drupal_data/default.settings.php
drush si standard --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}/${MYSQL_DATABASE} --account-name=admin --account-pass=${LDAP_PASSWD} -v
chmod a+w /drupal_data/files

# setup the LDAP server
drush pm-enable ldap_servers

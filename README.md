# drupal_docker
Docker image with Drupal instance ready for LDAP and use inside community-project

The included script `installation.sh` expects environment variables to be set:

Variable         | content
:----------------|:----------------------------------
MYSQL_USER       | MySQL username
MYSQL_PASSWORD   | password of our mysql user
MYSQL_HOST       | host of the mysql server
MYSQL_DATABASE   | name of the database
LDAP_PASSWD      | password of the admin account

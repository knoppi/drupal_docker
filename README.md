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
smtp_from        | address from that drupal mails shall be sent
smtp_fromname    | name of mail sender shown
smtp_host        | hostname of you smtp server
smtp_username    | username for your smtp server
smtp_password    | password for your smtp server
smtp_port        | port of your smtp server (25 for unencrypted transfer, usually 465 for SSL and TLS)
smtp_client_hostname | later content of mail header "hostname"

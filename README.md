# drupal_docker
Docker image with Drupal instance ready for LDAP-attachement. It uses the module smtp for mail transfer.

Now shipped with docker-compose.yaml for easy, quick testing.
Just adjust the variables in the file (see below), type docker-compose up and wait for about 30 seconds.
Then you can point a browser to localhost and see the magic of Drupal.


The included script `entrypoint.sh` expects environment variables to be set -- at least during first run

Variable         | content
:----------------|:----------------------------------
MYSQL_USER       | MySQL username
MYSQL_PASSWORD   | password of our mysql user
MYSQL_HOST       | host of the mysql server
MYSQL_DATABASE   | name of the database
LDAP_PASSWD      | password of the admin account
SITE_NAME        | name of the Drupal instance
smtp_from        | address from that drupal mails shall be sent
smtp_fromname    | name of mail sender shown
smtp_host        | hostname of you smtp server
smtp_username    | username for your smtp server
smtp_password    | password for your smtp server
smtp_port        | port of your smtp server (25 for unencrypted transfer, usually 465 for SSL and TLS)
smtp_client_hostname | later content of mail header "hostname"

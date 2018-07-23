FROM drupal:7-apache

# Some software we need for the later extensions of php
RUN apt-get update && apt-get purge -y sendmail && apt-get install -y libldap2-dev libmcrypt-dev ssmtp vim && rm -rf /var/lib/apt/lists/*

# We want to authorize using a central LDAP directory
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap

# The query-user needs a password stored in the drupal db, mcrypt helps to encrypt it
RUN docker-php-ext-install mcrypt

# German language
#ENV url https://ftp.drupal.org/files/translations/8.x/drupal/drupal-8.5.5.de.po
#ENV md5_sum f68995d21cfd09824bd6b8a652a6c9dd
#ENV filename drupal-8.5.5.de.po
ENV url https://ftp.drupal.org/files/translations/7.x/drupal/drupal-7.59.de.po
ENV md5_sum 540f6716d756592147f4ac3e0eb20cc6
ENV filename drupal-7.59.de.po

WORKDIR /var/www/html/profiles/standard/translations
RUN curl -s -o $filename $url \
    && md5sum $filename \
    && echo $md5_sum $filename | md5sum -c

# build modules
WORKDIR /var/www/html/modules

# Note to myself: Release information to the module can be found under
# https://www.drupal.org/project/!!!!/releases

# devel module
#ENV url https://ftp.drupal.org/files/projects/devel-8.x-1.2.tar.gz
#ENV md5_sum 2e43e3f78d37fbe5de88966414867c22
ENV url https://ftp.drupal.org/files/projects/devel-7.x-1.6.tar.gz
ENV md5_sum 1176b4c249ef0c398a763c6ffcc9b18c
ENV filename module.tar.gz
RUN curl -s -o $filename $url \
    && echo $md5_sum $filename | md5sum -c \
    && tar zxf $filename \
    && rm $filename

# entity module
#ENV url https://ftp.drupal.org/files/projects/entity-8.x-1.0-beta4.tar.gz
#ENV md5_sum 874c0a5c1915275c637f6692cba316d7
ENV url https://ftp.drupal.org/files/projects/entity-7.x-1.9.tar.gz
ENV md5_sum 793870ebcaa31da748e165d470c0b9bb
ENV filename module.tar.gz
RUN curl -s -o $filename $url \
    && echo $md5_sum $filename | md5sum -c \
    && tar zxf $filename \
    && rm $filename

# LDAP module
#ENV url https://ftp.drupal.org/files/projects/ldap-8.x-3.0-beta4.tar.gz
#ENV md5_sum 96169f21378d561ea819b69415ba6012
ENV url https://ftp.drupal.org/files/projects/ldap-7.x-2.3.tar.gz
ENV md5_sum cb7b235060185caf8da03fd5be5b7917
ENV filename module.tar.gz
RUN curl -s -o $filename $url \
    && echo $md5_sum $filename | md5sum -c \
    && tar zxf $filename \
    && rm $filename

# smtp module
#ENV url https://ftp.drupal.org/files/projects/smtp-8.x-1.0-beta4.tar.gz
#ENV md5_sum 8c8a6b05c001077ed79e7ea212dd8152
ENV url https://ftp.drupal.org/files/projects/smtp-7.x-1.7.tar.gz
ENV md5_sum c0184179267654a739306af63fbf267f
ENV filename module.tar.gz
RUN curl -s -o $filename $url \
    && echo $md5_sum $filename | md5sum -c \
    && tar zxf $filename \
    && rm $filename


# ctools module
#ENV url https://ftp.drupal.org/files/projects/ctools-8.x-3.0.tar.gz
#ENV md5_sum a234f3c5b8565122c9d7e9898836cca5
ENV url https://ftp.drupal.org/files/projects/ctools-7.x-1.14.tar.gz
ENV md5_sum 88dbe403ecfe2fe434f4237e5fd5ec67
ENV filename module.tar.gz
RUN curl -s -o $filename $url \
    && echo $md5_sum $filename | md5sum -c \
    && tar zxf $filename \
    && rm $filename

RUN chown -R www-data:www-data *

RUN mkdir -p /opt

WORKDIR /opt

# drush module
#ENV url https://ftp.drupal.org/files/projects/drush-8.x-6.0-rc4.tar.gz
#ENV md5_sum 9b0782978de72a972ce201a9dd288e23
ENV url https://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz
ENV md5_sum 70feb5cb95e7995c58cbf709a6d01312
ENV filename module.tar.gz
RUN curl -s -o $filename $url \
    && echo $md5_sum $filename | md5sum -c \
    && tar zxf $filename \
    && rm $filename

RUN chown -R www-data:www-data *

RUN chmod u+x drush/drush \
    && ln -s /opt/drush/drush /usr/bin/drush

#COPY settings.php /var/www/html/sites/default/
#RUN cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php

WORKDIR /var/www/html/sites/default

RUN sed 's+\$databases = array();+\$databases = array ( \
    "default" => array ( \
        "default" => array ( \
            "database" => getenv("MYSQL_DATABASE"),  \
            "username" => getenv("MYSQL_USER"),  \
            "password" => getenv("MYSQL_PASSWORD"),  \
            "host" => getenv("MYSQL_HOST"),  \
            "port" => "",  \
            "driver" => "mysql",  \
            "prefix" => '',  \
        ),  \
    ),  \
);+' default.settings.php > settings.php

WORKDIR /var/www/html

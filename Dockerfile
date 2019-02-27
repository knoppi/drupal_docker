FROM drupal:7-apache

# Some software we need for the later extensions of php
RUN apt-get update && apt-get purge -y sendmail \
  && apt-get install -y libldap2-dev libmcrypt-dev ssmtp vim \
  && rm -rf /var/lib/apt/lists/*

# We want to authorize using a central LDAP directory
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap

# The query-user needs a password stored in the drupal db, mcrypt helps to encrypt it
RUN docker-php-ext-install mcrypt

# German language
WORKDIR /var/www/html/profiles/standard/translations
RUN curl -s -o drupal-7.64.de.po \
  https://ftp.drupal.org/files/translations/7.x/drupal/drupal-7.64.de.po

# build modules
WORKDIR /var/www/html/modules

# Note to myself: Release information to the module can be found under
# https://www.drupal.org/project/!!!!/releases

# smtp module
ENV url https://ftp.drupal.org/files/projects/smtp-7.x-1.7.tar.gz
ENV md5_sum c0184179267654a739306af63fbf267f
RUN curl -s -o module.tar.gz $url \
    && echo $md5_sum module.tar.gz | md5sum -c \
    && tar zxf module.tar.gz && rm module.tar.gz

# devel module
ENV url https://ftp.drupal.org/files/projects/devel-7.x-1.6.tar.gz
ENV md5_sum 1176b4c249ef0c398a763c6ffcc9b18c
RUN curl -s -o module.tar.gz $url \
    && echo $md5_sum module.tar.gz | md5sum -c \
    && tar zxf module.tar.gz && rm module.tar.gz

# entity module
ENV url https://ftp.drupal.org/files/projects/entity-7.x-1.9.tar.gz
ENV md5_sum 793870ebcaa31da748e165d470c0b9bb
RUN curl -s -o module.tar.gz $url \
    && echo $md5_sum module.tar.gz | md5sum -c \
    && tar zxf module.tar.gz && rm module.tar.gz

# LDAP module
ENV url https://ftp.drupal.org/files/projects/ldap-7.x-2.3.tar.gz
ENV md5_sum cb7b235060185caf8da03fd5be5b7917
RUN curl -s -o module.tar.gz $url \
    && echo $md5_sum module.tar.gz | md5sum -c \
    && tar zxf module.tar.gz && rm module.tar.gz

# ctools module
ENV url https://ftp.drupal.org/files/projects/ctools-7.x-1.14.tar.gz
ENV md5_sum 88dbe403ecfe2fe434f4237e5fd5ec67
RUN curl -s -o module.tar.gz $url \
    && echo $md5_sum module.tar.gz | md5sum -c \
    && tar zxf module.tar.gz && rm module.tar.gz

# drush module
WORKDIR /opt
ENV url https://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz
ENV md5_sum 70feb5cb95e7995c58cbf709a6d01312
RUN curl -s -o module.tar.gz $url \
    && echo $md5_sum module.tar.gz | md5sum -c \
    && tar zxf module.tar.gz && rm module.tar.gz

RUN chmod u+x drush/drush \
    && ln -s /opt/drush/drush /usr/bin/drush

RUN chown -R www-data:www-data /opt /var/www/html

# create a backup of the image contents of specific folders
WORKDIR /bak
RUN mv /var/www/html/sites /var/www/html/themes ./

WORKDIR /var/www/html/
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

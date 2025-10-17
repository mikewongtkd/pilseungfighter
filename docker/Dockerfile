FROM php:8.2-apache
COPY bin/install.sh /freescore/docker/bin/install.sh
COPY psf.conf /etc/apache2/conf-enabled
RUN sh /freescore/docker/bin/install.sh
EXPOSE 3080
WORKDIR /usr/local/psf

# Use the official Ubuntu as a base image
FROM ubuntu:20.04

# Set ARG for noninteractive frontend
ARG DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /var/www/html/

# Update package repositories
RUN apt-get update

# INSTALL SYSTEM UTILITIES
RUN apt-get install -y \
    apt-utils \
    curl \
    git \
    apt-transport-https \
    software-properties-common \
    g++ \
    build-essential 

# INSTALL APACHE2
RUN apt-get install -y apache2
RUN a2enmod rewrite

# INSTALL locales
RUN apt-get install -qy language-pack-en-base \
    && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# INSTALL PHP & LIBRARIES
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

RUN apt-get --no-install-recommends --no-install-suggests --yes --quiet install \
    php-pear \
    php8.1 \
    php8.1-common \
    php8.1-mbstring \
    php8.1-dev \
    php8.1-xml \
    php8.1-cli \
    php8.1-mysql \
    php8.1-sqlite3 \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-gd \
    php8.1-imagick \
    php8.1-xdebug \
    php8.1-xml \
    php8.1-zip \
    php8.1-odbc \
    php8.1-opcache \
    php8.1-redis \
    autoconf \
    zlib1g-dev \
    libapache2-mod-php8.1

# INSTALL ODBC DRIVER & TOOLS


RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y \
    msodbcsql18 \
    mssql-tools18 \
    unixodbc \
    unixodbc-dev

RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
RUN exec bash

# INSTALL & LOAD SQLSRV DRIVER & PDO
RUN pecl install sqlsrv
RUN echo "extension=sqlsrv.so" > /etc/php/8.1/cli/conf.d/20-sqlsrv.ini
RUN echo "extension=sqlsrv.so" > /etc/php/8.1/apache2/conf.d/20-sqlsrv.ini

RUN pecl install pdo_sqlsrv
RUN echo "extension=pdo_sqlsrv.so" > /etc/php/8.1/cli/conf.d/30-pdo_sqlsrv.ini
RUN echo "extension=pdo_sqlsrv.so" > /etc/php/8.1/apache2/conf.d/30-pdo_sqlsrv.ini

# install gRPC 
RUN pecl install gRPC
RUN echo "extension=grpc.so" > /etc/php/8.1/cli/conf.d/40-grpc.ini
RUN echo "extension=grpc.so" > /etc/php/8.1/apache2/conf.d/40-grpc.ini

# install protobuf
RUN pecl install protobuf
RUN echo "extension=protobuf.so" > /etc/php/8.1/cli/conf.d/50-protobuf.ini
RUN echo "extension=protobuf.so" > /etc/php/8.1/apache2/conf.d/50-protobuf.ini
# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Cleanup
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose port 8000 to access Laravel's built-in server
EXPOSE 8000

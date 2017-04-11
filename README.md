# Vagrant PHP 7 Box
A setup and provisioning script for the lightweight [PHP 7 Vagrant box](https://atlas.hashicorp.com/ncaro/boxes/php7-debian8-apache-nginx-mysql/). Run your PHP applications in an extremely performant Vagrant Debian/PHP 7 environment.

## Installed with
- Debian 8 (Jessie)
- PHP 7
- PHP 5.6
- PHP-FPM
- MySQL 5.7
- Apache
- Nginx
- Memcached
- Redis
- Node.js
- NPM
- Grunt
- Gulp
- Bower
- Composer

## How to use
Map the folders you'd like to sync with Vagrant in the `config.yaml` file. By default, if you place this in the root of your project, it will use that folder. Choose your PHP version and preferred server (defaults to PHP 7 and nginx).

Run `vagrant up`. That's all.

## MySQL
You can access the MySQL instance through SSH, credentials as follows:

```
MySQL Host: 127.0.0.1
Username: root
Password: root
Port: 3306

SSH IP: {your-ip}
SSH User: vagrant
SSH Password: vagrant
SSH Key: ~/.vagrant.d/insecure_private_key (this may be different depending on your environment)
SSH Port: 2222
```

## Install TLS
[Adding SSL to local.dev](https://www.njimedia.com/local-development-with-ssl-tls-p2/)

`mkdir cert; cd cert`

`openssl req -new -newkey rsa:2048 -nodes -keyout domain_dev.key -out domain_dev.csr`

`openssl x509 -req -days 365 -in domain_dev.csr -signkey domain_dev.key -out domain_dev.crt`

`vagrant up && vagrant ssh`

`vi /etc/apache2/sites-enabled/default-ssl.conf`

Modify these lines in .conf
```
SSLCertificateFile      /var/www/cert/domain_dev.crt
SSLCertificateKeyFile   /var/www/cert/domain_dev.key
```

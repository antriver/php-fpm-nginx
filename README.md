# Docker php-fpm-nginx Image

This image contains PHP-FPM and Nginx in one container.
It is intended as an alternative to using a separate Nginx container with a PHP-FPM container, and to using the official PHP Apache images.
This is inspired by https://github.com/TrafeX/docker-php-nginx but this uses the official PHP-FPM image as a base instead of installing PHP.

# Building and Publishing

To build and publish the image, run the following commands:

    ./build.sh

## Usage

Run the image with your application mounted, and your application's Nginx configuration mounted in `/etc/nginx/sites-enabled/`.

    docker run -p 80:80 -p 443:443 -v `pwd`:/var/www/app -v `pwd`/nginx.conf:/etc/nginx/sites-enabled/app.conf antriver/php-fpm-nginx:latest

FROM php:8.3.10-fpm

RUN apt update

# Install PHP extensions for Laravel
RUN docker-php-ext-install mysqli pdo pdo_mysql bcmath && docker-php-ext-enable pdo_mysql bcmath
RUN pecl install timezonedb && docker-php-ext-enable timezonedb

# Add PHP configuration
COPY config/php/fpm/conf.d/99-custom.ini /etc/php/8.3/fpm/conf.d/99-custom.ini
COPY config/php/fpm/pool.d/zzz-custom.conf /usr/local/etc/php-fpm.d/zzz-custom.conf

# Install Nginx
RUN apt install -y nginx

# Add Nginx configuration
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/fastcgi.conf /etc/nginx/fastcgi.conf
COPY config/nginx/conf.d /etc/nginx/conf.d/
COPY config/nginx/snippets /etc/nginx/snippets/

# Remove default Nginx server
RUN rm /etc/nginx/sites-enabled/default

# Install Supervisor
RUN apt install -y supervisor

# Add supervisor configuration
COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
WORKDIR /var/www/app

# Expose the port nginx is reachable on
EXPOSE 80
EXPOSE 443

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

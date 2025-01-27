FROM php:8.4.3-fpm

RUN apt update

# Install PHP extensions for Laravel
RUN docker-php-ext-install mysqli pdo pdo_mysql bcmath && docker-php-ext-enable pdo_mysql bcmath
RUN pecl install timezonedb && docker-php-ext-enable timezonedb

# Add PHP configuration
COPY config/php/fpm/conf.d/99-custom.ini /usr/local/etc/php/conf.d/99-custom.ini

# Add Nginx repository (see https://nginx.org/en/linux_packages.html#Debian)

# Install the prerequisites:
RUN apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring

# Import an official nginx signing key so apt could verify the packages authenticity. Fetch the key:
RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
        | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# To set up the apt repository for stable nginx packages, run the following command:
RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    http://nginx.org/packages/debian `lsb_release -cs` nginx" \
        | tee /etc/apt/sources.list.d/nginx.list

# Set up repository pinning to prefer our packages over distribution-provided ones:
RUN echo "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
        | tee /etc/apt/preferences.d/99nginx

RUN apt update

# Install Nginx
RUN apt install -y nginx

# Add Nginx configuration
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/fastcgi.conf /etc/nginx/fastcgi.conf
COPY config/nginx/conf.d /etc/nginx/conf.d/
COPY config/nginx/snippets /etc/nginx/snippets/

# Remove default Nginx server
# RUN rm /etc/nginx/sites-enabled/default



# Install Supervisor
RUN apt install -y supervisor

# Add Supervisor configuration
COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
WORKDIR /var/www/app

# Expose standard HTTP(S) ports
EXPOSE 80
EXPOSE 443

# Let Supervisor start Nginx & PHP-FPM
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Docker php-fpm-nginx Image

This image contains PHP-FPM and Nginx in one container.
It is intended as an alternative to using a separate Nginx container with a PHP-FPM container, or using the official PHP Apache images.
This is inspired by https://github.com/TrafeX/docker-php-nginx but this uses the official PHP-FPM image as a base instead of installing PHP.

## Usage

Run the image with your application mounted, and your application's Nginx configuration mounted in `/etc/nginx/sites-enabled/`.
You can mount the app anywhere you like as long as this is reflected in your Nginx config.

    docker run \
        -p 8080:80 \
        -v /path/to/your/app:/var/www/app \
        -v /path/to/your/app/config/nginx/app.conf:/etc/nginx/sites-enabled/app.conf \
        antriver/php-fpm-nginx:latest

In this example:
- **8080:80** means we want to connect the local port 8080 to the container's port 80.
- **/path/to/your/app** is the absolute path to your application code.
- **/path/to/your/app/config/nginx/app.conf** is the absolute path to your Nginx site configuration file.


### Example Nginx Configuration

```
server {
    listen 80 default;

    root /var/www/app/public;

    access_log /var/log/nginx/access.log main buffer=32k flush=1m;
    error_log /var/log/nginx/error.log error;

    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        # Send requests to PHP.
        
        fastcgi_intercept_errors on;
        
        # regex to split $uri to $fastcgi_script_name and $fastcgi_path
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        
        # Check that the PHP script exists before passing it
        try_files $fastcgi_script_name =404;
        
        # Bypass the fact that try_files resets $fastcgi_path_info
        # see: http://trac.nginx.org/nginx/ticket/321
        set $path_info $fastcgi_path_info;
        fastcgi_param PATH_INFO $path_info;
        
        fastcgi_index index.php;
        
        include fastcgi.conf;

        fastcgi_pass php;
    }
}
```

You can also use the provided "snippet" in your Nginx configuration file to send requests to PHP.
The snippet contains the same configuration as the example above.
```
server {
    listen 80 default;

    root /var/www/app/public;

    access_log /var/log/nginx/access.log main buffer=32k flush=1m;
    error_log /var/log/nginx/error.log error;

    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        # Send requests to PHP.
        include snippets/php.conf;
    }
}
```

## Configuration

### PHP

You can add additional PHP configuration files by mounting those too, e.g.

    docker run \
        -p 8080:80 \
        -v /path/to/your/app:/var/www/app \
        -v /path/to/your/app/config/nginx/app.conf:/etc/nginx/sites-enabled/app.conf \
        -v /path/to/your/app/config/php.ini:/usr/local/etc/php/conf.d/99-custom.ini \
        antriver/php-fpm-nginx:latest

In addition to the default example above we also have:
- **/path/to/your/app/config/php/php.ini** is the path to an additional PHP configuration file to be included.

### Nginx

You can add replace the Nginx server configuration with your own by mounting that, e.g.

    docker run \
        -p 8080:80 \
        -v /path/to/your/app:/var/www/app \
        -v /path/to/your/app/config/nginx/app.conf:/etc/nginx/sites-enabled/app.conf \
        -v /path/to/your/app/config/nginx/nginx.conf:/etc/nginx/nginx.conf \
        antriver/php-fpm-nginx:latest

In addition to the default example above we also have:
- **/path/to/your/app/config/nginx/nginx.conf** is the path to replacement configuration for the Nginx server.

## Building and Publishing The Image

To build the image, run the following command:

    ./build.sh

To build and publish the image, run the following command:

    ./build.sh --publish

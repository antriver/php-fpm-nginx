#!/bin/bash

set -e

# Build the image and tag it as latest.
docker build -t antriver/php-fpm-nginx:latest .

# Generate a version string based on the PHP and Nginx versions.
# e.g. php8.3.10-nginx1.22.1
# See https://unix.stackexchange.com/questions/471521/how-to-get-only-the-version-number-of-php-using-shell-commands
# See https://stackoverflow.com/questions/50729099/bash-nginx-version-check-cut
# echo -n is used to remove the newline character at the end of the output.
VERSION=`docker run -it antriver/php-fpm-nginx:latest bash -c "echo -n php\\\`php -r 'echo PHP_VERSION;'\\\`-nginx\\\`nginx -v 2>&1 | cut -d'/' -f2\\\`"`

echo "Tagging as version $VERSION"

# Tag the latest image with the correct version.
docker image tag antriver/php-fpm-nginx:latest antriver/php-fpm-nginx:$VERSION

# Push the latest versioned images to Docker Hub.
# TODO

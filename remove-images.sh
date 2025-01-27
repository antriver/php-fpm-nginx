#!/bin/bash

docker rmi --force $(docker images -q 'antriver/php-fpm-nginx' | uniq)

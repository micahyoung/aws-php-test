#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

source env.sh
: ${AWS_ACCESS_KEY_ID:?"1"}
: ${AWS_SECRET_ACCESS_KEY:?"1"}

if ! [ -d aws-php-sample/vendor ]; then
  pushd aws-php-sample/
    composer install
  popd
fi

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

pushd aws-php-sample/
  php --php-ini ../php.ini sample.php
popd

pushd aws-php-sample/
  cf push aws-php-sample --no-start -c 'php /home/vcap/app/htdocs/sample.php' --health-check-type process -b php_buildpack --no-route
popd

trap "cf delete -f aws-php-sample" EXIT

cf set-env aws-php-sample AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
cf set-env aws-php-sample AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY
cf start aws-php-sample
cf logs aws-php-sample

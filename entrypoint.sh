#!/bin/sh

set -e


echo "Environment: $RACK_ENV"

# install missing gems
bundle check || bundle install --jobs 20 --retry 5

# Remove pre-existing puma/passenger server.pid
rm -f $APP_PATH/tmp/pids/server.pid
rm -f $APP_PATH/test-server-*.log

# run passed commands
bundle exec ${@}
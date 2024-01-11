#!/bin/bash

# Run bundle install
bundle install

# Add the cronjob entry to run every 3 minutes
whenever --update-crontab

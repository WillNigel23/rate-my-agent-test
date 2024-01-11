# Automated Website Availability Checker

Author: Will Nigel C. De Jesus
Version: Ruby 3.2.2

## Full setup with cron

1. Clone the repo 

`git clone https://github.com/WillNigel23/rate-my-agent-test.git`

`cd rate-my-agent-test`

2. Make `setup.sh` executable

`chmod +x setup.sh`

3. Run `setup.sh`

`./setup.sh`

## Running just the script

1. Clone the repo 

`git clone https://github.com/WillNigel23/rate-my-agent-test.git`

`cd rate-my-agent-test`

2. Install dependencies

`bundle install`

3. Run test.rb

`bundle exec ruby test.rb`

## Features

1. Runs 3 tests

    - Test Status (get request to 'rate-my-agent.com' to return status code 200)

    - Test Search with expected results (from 'rate-my-agent.com' homepage, search for keyword 'Toronto'. We are expecting to see results so the empty search query error should not appear)

    - Test Search without expected result (from 'rate-my-agent.com' homepage, search for keyword 'asdasdasd'. We are not expecting to see any query result so the placeholder error should appear) 

2. Logs file generated

    - log files in HTML format are generated in `#{timestamp}_logs.html` filename format

    - Includes metadata for the logs as well as highlighting whenever there are errors/failed tests.

3. Email

    - Initially disabled. Need to provide a valid working SMTP configuration for it to work
    - ```
  # Uncomment MAIL_OPTIONS and delete MAIL_OPTIONS = nil
  # Setup a valid SMTP configuration for mailing to work
  # Mailing disabled by default
  MAIL_OPTIONS = nil
  #MAIL_OPTIONS = {
  #  address: 'smtp.example.com',
  #  port: 587,
  #  user_name: 'your_email@example.com',
  #  password: 'your_email_password',
  #  authentication: 'plain',
  #  enable_starttls_auto: true
  #}
```

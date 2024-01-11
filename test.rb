require 'selenium-webdriver'
require 'test-unit'
require 'mail'

class RateMyAgentTest < Test::Unit::TestCase
  @@log_initialized = false
  @@logfile_name = nil
  @@logger = nil
  @@error_encountered = false
  ALERT_EMAIL = 'alerts@rate-my-agent.com'
  
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
  def setup
    options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    @driver = Selenium::WebDriver.for :firefox, options: options
    @url = "https://www.rate-my-agent.com/"
    @driver.manage.timeouts.implicit_wait = 30

    initialize_log unless @@log_initialized
  end
  def test_status
    begin
      # Perform a GET request
      uri = URI(@url)
      response = Net::HTTP.get_response(uri)

      # Check if the status code is equal to 200
      assert_equal(200, response.code.to_i, "Unexpected status code: #{response.code}")

      success_message = "Test status passed for URL: #{@url}"
      @@logger.info("<br><h2>Test Status</h2><br><p>#{success_message}</p><br>")
      puts success_message
    rescue StandardError => e
      # Log error message
      error_message = "An error occurred during test_status: #{e.message}"
      @@logger.error("<br><h2>Test Status</h2><br><p style='color:red;'>#{error_message}</p><br>")
      @@logger.error(e.backtrace.join("\n"))
      puts error_message
      @@error_encountered = true
      raise
    end
  end
  def test_search_with_result
    # Search for keyword 'Toronto'
    # We expect this to give us valid search results
    begin
      success_message = 'Test search with results passed'
      error_message = 'An error occurred during test_search_with_result'

      search('Toronto', true)
      @@logger.info("<br><h2>Test Search With Results</h2><br><p>#{success_message}</p><br>")
      puts success_message
    rescue StandardError => e
      # Log error message
      @@logger.error("<br><h2>Test Search With Results</h2><br><p style='color:red;'>#{e.message}</p><br>")
      @@logger.error(e.backtrace.join("\n"))
      puts error_message
      @@error_encountered = true
      raise
    end
  end
  def test_search_without_result
    # Search for keyword 'asdasdasd'
    # We expect this to give us NO valid search result
    begin
      success_message = 'Test search without results passed'
      error_message = 'An error occurred during test_search_without_result'

      search('asdasdasd', false)
      @@logger.info("<br><h2>Test Search Without Results</h2><br><p>#{success_message}</p><br>")
      puts success_message
      end_html_log
    rescue StandardError => e
      @@logger.error("<br><h2>Test Search Without Results</h2><br><p style='color:red;'>#{e.message}</p><br>")
      @@logger.error(e.backtrace.join("\n"))
      puts error_message
      @@error_encountered = true
      end_html_log
      send_email if @@error_encountered and !MAIL_OPTIONS.nil?
      raise
    end 
  end
  def teardown
    @driver.quit
  end
  private
  def send_email
    subject = "Test Failure Alert - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    body = "The automated tests have failed. Please check the attached log file for details."

    Mail.defaults do
      delivery_method :smtp, MAIL_OPTIONS
    end

    mail = Mail.new do
      from 'your_email_address' # Add in your email address
      to ALERT_EMAIL
      subject subject
      body body
      add_file @@log_filename
    end

    mail.deliver

    @@email_sent = true
  end
  def initialize_log
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    @@log_filename = "#{timestamp}_logs.html"
    @@logger = Logger.new(@@log_filename)

    # Start the HTML log with basic structure and timestamp
    start_html_log

    @@log_initialized = true
  end
  def start_html_log
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    @@logger.info("<html><head><title>Test Log - #{timestamp}</title></head><body><h1>Test Logs - #{timestamp}</h1><br><br>")
  end
  def end_html_log
    @@logger.info("</body></html>")
  end
  def search(search_key, expects_result)
    @driver.get(@url)

    # Wait to ensure page finishes loading
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)

    # Get search box, fill with details and submit
    form_element = wait.until { @driver.find_element(:css, '.container .form-home-search[action="/search"]') }
    input_element = form_element.find_element(:id, 'term')
    input_element.send_keys(search_key)
    form_element.submit

    # Wait until redirect is complete 
    wait.until { @driver.current_url != @url }

    # Check for the expected url format from the search
    expected_url = "https://www.rate-my-agent.com/search?utf8=%E2%9C%93&term=#{search_key}"
    actual_url = @driver.current_url
    assert_equal(expected_url, actual_url, "Unexpected URL: #{actual_url}")

      # Check if the search result is valid 
      error_message_element = @driver.find_elements(:css, 'h3').find { |element| element.text.include?('Please check your spelling and try again.') }
    if expects_result
      # Expects results so error message should not be found
      assert_nil(error_message_element, 'Error message is present. Search failed.')
    else
      # Expects no result so error message should be found
      assert_not_nil(error_message_element, 'Error message is present. Search failed.')
    end 
  end
end

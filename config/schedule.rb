ENV.each { |k, v| env(k, v) }
pwd = "#{Dir.pwd}"

every 3.minutes do
  command "cd #{pwd} && ruby test.rb >> crontab_logs.txt 2>&1"
end

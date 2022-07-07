require 'pry'
require 'capybara'
require 'selenium-webdriver'
require './storage'


Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.default_driver = :chrome
Capybara.javascript_driver = :chrome

COUNTDOWN = 1
ATTEMPTS = 1000

NAME = "Enter a name here" # or use faker
PHONE_NUMBER = "Enter a phone number here" # or user faker

@storage = Storage.new

# Set up an email

ATTEMPTS.times do
  puts 'Starting..'
  sleep(rand(5)) # sleep a random time to mimic a user

  email_thread = Thread.new do
    session = Capybara::Session.new(:chrome)
    sleep COUNTDOWN # wait for browser

    session.visit('https://temp-mail.org/en/')
    sleep 10 # wait a sec for the email to load
    @email = session.find('input#mail').value

    # we dont care for the email after this because
    # we arent checking the inbox; the website displays the code
    session.driver.quit
  end


  bar_thread = Thread.new do
    session = Capybara::Session.new(:chrome)
    sleep COUNTDOWN # wait for browser

    session.visit('https://www.simmonsbar.co.uk/#prizes')

    sleep 1 while @email.nil? # wait till we have an email from the other browser.

    # Close the modal
    sleep 5
    session.execute_script('document.getElementsByClassName("boxzilla-close-icon")[0].click()')

    email_input = session.find('input[placeholder=\'Your email\']')
    name_input  = session.find('input[placeholder=\'Name\']')
    phone_input = session.find('input[placeholder=\'Phone Number\']')
    spin_button = session.find('button#spin_wheel')

    email_input.set(@email)
    name_input.set(NAME)
    phone_input.set(PHONE_NUMBER)

    sleep 5 # wait a sec just to be sure

    # Click the button in JS to imitate client
    # capybara doesnt like it when we .click cause it gets intercepted by their js to submit it
    # since it's not a real form

    # Submit the spin

    submit_error = begin
      session.execute_script('document.getElementById("spin_wheel").click()')
      sleep 0.2 # find it quick cause it shows straight away
      session.find('.wof-error')
    rescue
      nil
    end

    if submit_error.nil?
      begin
        sleep 15 # wait for the text to show and the wheel to spin
        win_text = session.find('.wof-winnings').text
        @storage.add(win_text: win_text)
      rescue => e
        # if for some reason it cant do ANYTHING
        # maybe we won the big prize and the whole website changed??
        # so just screenshot the entire thing so we can manually look at it
        puts "ERROR: #{e.message}"
        filename = "attempt_#{Time.now.strftime("%d_%m_%y_%T").gsub(':', '_')}.png"
        session.save_screenshot("./screenshots/#{filename}", full: true)
        puts "Screenshot saved: #{filename}"
      end
    end


    session.driver.quit
  end

  email_thread.join
  bar_thread.join
  Capybara.reset_sessions!
end


# Finish the threads before exiting the program so it
# doesn't shut down the main thread of execution before they finish and halt everything


# Quit the sessions
# Capybara.send(:session_pool).each { |name, ses| ses.driver.quit }


exit(0)

require "rubygems"
require "bundler/setup"
require "nokogiri"
require "mechanize"
require "./non_wish_list"

class Birthday

  BASE_URL = 'https://m.facebook.com'

  def run!
    agent.get(BASE_URL) if agent.page.nil?
    sign_in
    wish_happy_birthday
  end

  def wish_happy_birthday
    find_todays_bdays.each do |name|
      puts "Wishing Happy Birthday to....#{name}"
      download_image(name)

      agent.get "#{BASE_URL}/birthdays"
      agent.click("#{name}")

      add_image(name)
      back_to_birthday_page
    end
  end

  def find_todays_bdays
    agent.get "#{BASE_URL}/birthdays"
    next_element = page.at('h4').next
    bday_array = todays_bdays(next_element)

    puts "Today's bdays - #{bday_array}"
    bday_array - non_wish_list
  end

  def todays_bdays(next_element, bday_names=[])
    if next_element
      bday_names << next_element.child.text
      next_element = next_element.next
      todays_bdays(next_element, bday_names)
    end
    bday_names
  end

  def random_pause
    sleep rand(8) + 1
  end

  def non_wish_list
    NonWishList.list
  end

  def back_to_birthday_page
    random_pause
    agent.get "#{BASE_URL}/birthdays"
    random_pause
  end

  def fill_in(message)
    form.textareas.first.value = "#{message}"
  end

  def download_image(name)
    agent.get "http://images.google.com"
    first_name = name.split.first
    form.fields[4].value = "Happy Birthday #{first_name}"
    form.submit

    image_link = page.search("img").first.attributes["src"].value
    agent.get(image_link).save_as "#{first_name}.jpg"
  end

  def add_image(name)
    first_name = name.split.first

    agent.click page.link_with(text: "Photo")

    form.file_uploads.first.file_name = "#{first_name}.jpg"
    fill_in("happy birthday!")

    random_pause
    form.submit
  end

  def sign_in
    puts "Signing in..."
    form.email = email
    form.pass = password
    form.submit
  end

  def email
    config['email']
  end

  def password
    config['password']
  end

  def agent
    @agent ||= Mechanize.new
  end

  def page
    agent.page
  end

  def form
    page.form
  end

  def config
    @config ||= read_config
  end

  def read_config
    Psych.load(File.read('config.yml'))
  end
end

birthday = Birthday.new
birthday.run!


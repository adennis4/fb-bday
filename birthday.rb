require "mechanize"
require "psych"
require 'yaml'

class Birthday

  BASE_URL = 'https://m.facebook.com'
  BIRTHDAY_MESSAGE = 'happy birthday!'

  def run!
    random_nap
    agent.get(BASE_URL)
    sign_in
    wish_happy_birthday
  end

  def wish_happy_birthday
    go_to_birthday_page
    find_todays_bdays.each do |name|
      puts "Wishing Happy Birthday to....#{name}"

      download_image(name)
      select_friend(name)
      add_image(name)
      cleanup_images
      File.open('cron.log', 'a') { |x| x.puts "#{name}" }
    end
  end

  def find_todays_bdays
    abort("...No birthdays today") unless page.at('h4').children.text == "Today"

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

  def go_to_birthday_page
    agent.get "#{BASE_URL}/birthdays"
  end

  def select_friend(name)
    go_to_birthday_page
    agent.click("#{name}")
  end

  def download_image(name)
    agent.get "http://images.google.com"
    first_name = name.split.first

    form.fields[4].value = "Happy Birthday #{first_name}"
    form.submit

    agent.get(select_image).save_as "#{first_name}.jpg"
  end

  def select_image
    links = page.links.select{ |link| link.href[1..6] == "imgres" }
    links[2].href.match(/=(.*)&img/)[1]
  end

  def add_image(name)
    first_name = name.split.first

    agent.click page.link_with(text: "More Options >>")
    agent.click page.link_with(text: "Share Photo")

    form.file_uploads.first.file_name = "#{first_name}.jpg"
    form.textareas.first.value = "#{BIRTHDAY_MESSAGE}"

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
    Psych.load(File.read('./config/config.yml'))
  end

  def random_nap
    sleep rand(600)
  end

  def non_wish_list
    YAML.load_file('./config/non_wish_list.yml')
  end

  def cleanup_images
    `rm *.jpg`
  end
end

require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'
require "down"
require "open-uri"

names = ["Steven S. Badin", "Mona L. Bashar", "Kenneth I. Berger", "Eric E. Bondarsky", "Shari B. Brosnahan", "Susan H. Cheng", "Myah A. Draine", "Ezra E. Dweck", "Kevin J. Felner", "Suzette A. Garofano", "Charlisa D. Gibson", "Ronald M. Goldenberg", "Roberta M. Goldring", "Allison A. Greco", "Jacklyn M. Hagedorn", "Denise J. Harrison", "John G. Hay", "David L. Kamelhar", "Lisa C. Kanengiser", "Brian S. Kaufman", "Marilyn Y. Kline", "Stephanie Lau", "Anthony S. Lubinsky", "Maria C. Mirant-Borde", "Bashar M. Mourad", "John S. Munger", "Beno W. Oppenheimer", "Nancy M. Partos", "Claudia S. Plottel", "Miera H. Rechtschaffen", "Pedro J. Rivera", "William N. Rom", "Gail E. Schattner", "Mark F. Sloane", "Robert L. Smith", "Polina Trachuk", "John K. Wang", "Michael D. Weiden", "Wendy J. Wise", "Benjamin Z. Wu"]

Selenium::WebDriver::Firefox::Service.driver_path = "C:/GeckoDriver/geckodriver.exe"
browser = Watir::Browser.new:firefox
browser.window.maximize
# url = 'http://www.luhs.org/phone_directory.cfm'
CSV.open("NYC_mail_1.csv", "w", {:col_sep => "~"}) do |csv|
	names.each do |each_name|
		begin
			# uri = URI.parse("https://www.nyu.edu/search.directory.html?search=#{each_name.gsub(' ',"%20")}&st=people")
			browser.goto("https://www.nyu.edu/search.directory.html?search=#{each_name.gsub(' ',"%20")}&st=people")
			sleep 2
			# if browser.h2(class: 'title').text.downcase.include?"#{each_name.downcase}"
				email = browser.a(class: 'contact-link').href
				csv << [each_name, browser.h2(class: 'title').text, email]
			# end
		rescue Exception => e
			puts "exception in #{each_name}\n #{e.message}"
		end
		
	end
end
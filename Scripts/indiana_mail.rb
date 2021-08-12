require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'


Selenium::WebDriver::Firefox::Service.driver_path = "C:/GeckoDriver/geckodriver.exe"
browser = Watir::Browser.new:firefox
browser.window.maximize
byebug
url = 'https://directory.iu.edu/'

CSV.open("Indiana_data_mail_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
name = ["Yen-Chun (Charly)  Lai, PhD", "Angelia D. Lockett, PhD,  BS", "Farzad  Loghmani, MD,  BS", "Roberto Machado, MD", "Shalini  Manchanda, MD", "Chris Naum, MD,  BA", "Tyson Neumann, MD,  BS", "Aliya  Noor, MD", "Michael Ober, MD", "Damien Patel, MD", "Mrunal Patel, MD", "Ilana  Porzecanski, MD", "Hari Puttagunta, MD", "Omar  Rahman, MD", "Scott Roberts, MD,  BS", "David Roe, MD", "Marc Rovner, MD,  MMM,  BSE", "Catherine Sears, MD", "Adil  Sheikh, MD,  FEL", "Francis Sheski, MD", "Asma Siddiqui, MD", "Ninotchka Sigua, MD", "Regg  Singh, MD,  BA", "Joseph Smith, MD", "Robert Spech, MD", "Stephanie Stahl, MD", "Bob  Stearman, PhD", "Homer wigg III, MD", "Mark Unroe, MD", "Robert Weller, MD,  BA", "Karl Yang, MD", "Lily Zeng, MD"]

name.each do |each_name|
	begin
		browser.goto(url)
		sleep 2
		browser.input(name: 'SearchText').send_keys"#{each_name.split(',').first}"
		browser.button(id: 'submit').click
		sleep 3
		email = browser.dt(text: 'Email').following_sibling.text
		name_d = browser.h2.text
		csv << [each_name, name_d, email]
	rescue Exception => e
		puts "Exception in #{each_name}\n #{e.message}"
	end

end
end
# byebug
puts url
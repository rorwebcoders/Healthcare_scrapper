require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'
require "down"
require "open-uri"

names = ["Sean Forsythe,  MD", "Majid Afshar, MD, MS", "Daniel Dilling, MD, FACP, FCCP, FAASM", "James Gagermeier, MD, ABIM", "Emily Gilbert, MD", "Amit Goyal, MD", "Paul Hutchison, MA", "Amal Jubran,  MD", "Sunita Kumar, MD, FCCP,  FAASM", "Franco Laghi, MD, FCCP", "Erin Lowery, MD, MS", "Shruti Patel, MD", "Sana Quddus, MD", "Kevin Simpson, MD, FACP, FCCP", "Martin J. Tobin, MD", "Nidhi Undevia, MD, DABSM, FAASM", "Brad Bemiss, MD", "Ejaaz Kalimullah, MD"]

Selenium::WebDriver::Firefox::Service.driver_path = "C:/GeckoDriver/geckodriver.exe"
browser = Watir::Browser.new:firefox
browser.window.maximize
url = 'http://www.luhs.org/phone_directory.cfm'
CSV.open("Loyola_mail.csv", "w", {:col_sep => "~"}) do |csv|
names.each do |each_name|
	browser.goto(url)
	sleep 2
	browser.input(name: 'fname').send_keys "#{each_name.split(',').first.split.first}"
	browser.input(type: 'submit').click
	sleep 2
	data = browser.trs.select{|e| e.text.include? "#{each_name.split(',').first.split.last}"}
	if data.count > 0
		puts data[0].tds.last.text
		csv << [each_name, data[0].tds[1].text, data[0].tds[2].text, data[0].tds.last.text]
	end
# byebug
end
end
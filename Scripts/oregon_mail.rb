require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'
require "down"
require "open-uri"

Selenium::WebDriver::Firefox::Service.driver_path = "C:/GeckoDriver/geckodriver.exe"
browser = Watir::Browser.new:firefox
browser.window.maximize

names = ["Terri Hough, MD MSc", "Gopal Allada, MD", "Alan Barker, MD", "Anna Brady, MD", "Laura Chess, MD", "Matthew Drake, MD", "Allison Fryer, PhD", "Sherie Gause, MD", "Shewit Giovanni, MD", "Jeffrey Gold, MD", "Stephen Hall, MD, PhD", "David Jacoby, MD", "Akram Khan, MD", "Brenda Marsh, MD, PhD", "Bart Moulton, MD", "Dane Nichols, MD", "Zhenying Nie, MD, PhD", "Stephanie Nonas, MD", "Jonathan Pak, MD", "Ran Ran, MD", "Jeff Robinson, MD", "Virginia Satcher, ANP", "Daniel Seifer, MD", "Donald Sullivan, MD, MA, MCR", "Aaron Trimble, MD", "Kelly Vranas, MD", "Bishoy Zakhary, MD", "Kathryn Artis, MD, MPH", "Mark Chesnutt, MD", "David Coultas, MD, FACP", "Mark Deffebach, MD", "Melanie Harriff, PhD", "William Holden, MD", "Elly Karamooz, MD", "Suil Kim, MD, PhD", "David Lewinsohn, MD, PhD", "Miranda Lim, MD, PhD", "Christian Morales Perez, MD", "Lakshmi Mudambi, MD", "Thomas Prendergast, MD", "Christopher Slatore, MD", "Stephen Smith MB, BS, PhD"]
url = 'https://ohsu.pure.elsevier.com/en/searchAll/advanced/?searchByRadioGroup=PartOfNameOrTitle&searchBy=PartOfNameOrTitle&allThese=&exactPhrase=&or=Gopal+Allada&minus=&family=&doSearch=Search&slowScroll=true&resultFamilyTabToSelect='
browser.goto(url)
sleep 2
CSV.open("Oregon_mail.csv", "w", {:col_sep => "~"}) do |csv|
names.each do |each_name|
	name_d = ''
	email = ''
	begin
		browser.input(placeholder: 'Type in optional words').to_subtype.clear
		browser.input(placeholder: 'Type in optional words').send_keys"#{each_name.split(',').first}"
		browser.input(type: 'submit').click
		sleep 2
		if browser.lis(class: 'grid-result-item').count > 0
			name_d = browser.lis(class: 'grid-result-item')[0].h3(class: 'title').text
			email = browser.lis(class: 'grid-result-item')[0].li(class: "email").text
		end
		csv << [each_name, name_d, email]
	rescue Exception => e
		puts "exception in #{each_name}\n #{e.message}"
		puts e.backtrace
	end
	
end
end
require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'
require "down"
require "open-uri"
require 'rtesseract'



names = ["Bruce David Levy, MD", "Raja-Elie E. Abdulnour, MD", "Rebecca Marlene Baron, MD", "Bartolome Celli, MD", "Manuela Cernadas, MD", "Barbara A. Cockrill Gootkind, MD", "Carolyn E. Come, MD", "Carolyn M. D'Ambrosio, MD", "Miguel J. Divo, MD, MPH", "Tracy Jennifer Doyle, MD", "Jeffrey Mark Drazen, MD", "Souheil Y. El-Chemaly, MD", "Gary Epler, MD", "Christopher Hardy Fanta, MD", "Laura E. Fredenburgh, MD", "Elizabeth B. Gay, MD", "Hilary J. Goldberg, MD", "Kathleen Joanne Haley, MD", "Elizabeth Petri Henske, MD", "Gary M. Hunninghake, MD", "Edward Ingenito, MD", "Elliot Israel, MD", "Steven P. Keller, MD, PhD", "Edy Yong Kim, MD, PhD", "Karen Charlene Lahive, MD", "Anthony Francis Massaro, MD", "Robert Joseph McCunney, MD", "William M. Oldham, MD, PhD", "Mark Anthony Perrella, MD", "James Roach, MD", "Scott Lewis Schissel, MD, PhD", "Nirmal Shyam Sharma, MD", "David M. Systrom, Jr., MD", "George Richard Washko, Jr., MD", "Aaron B. Waxman, MD, PhD", "Gerald Lawrence Weinhouse, MD", "David Joseph Kwiatkowski, MD, PhD", "Salma Batool-Anwar, MBBS, MPH", "Rohit Budhiraja, MD", "Michael Hyosang Cho, MD, MPH", "Craig P. Hersh, MD", "Augusto Litonjua, MD, MPH", "Benjamin A. Raby, MD, MPH", "Edwin Kepner Silverman, MD, PhD", "Deborah T. Hung, MD, PhD", "Chanu Rhee, MD, MPH", "Edward A Nardell, MD"]

Selenium::WebDriver::Firefox::Service.driver_path = "C:/GeckoDriver/geckodriver.exe"
browser = Watir::Browser.new:firefox
browser.window.maximize
url = 'https://connects.catalyst.harvard.edu/Profiles/display/Person/25016'
browser.goto(url)
names.each do |each_name|
	browser.input(id: 'menu-search').send_keys"#{each_name.split(',').first.split.first}"
	browser.send_keys :enter
	sleep 4
	# byebug
	data = browser.as.select{|e| e.text.include? "#{each_name.split(',').first.split.last}"}
	if data.count > 0
		details_url = data[0].href
		details_doc = Nokogiri::HTML(RestClient.get(details_url))
		email_link = details_doc.css('img.email-image').attr('src')
		open(email_link.value) do |image|
		  File.open("./#{each_name.split(',').first}.jpg", "wb") do |file|
		    file.write(image.read)
		  end
		end
		sleep 1
		image = RTesseract.new("#{each_name.split(',').first}.jpg", lang: 'eng')
		byebug
		email = iamge.to_s
		# byebug
	end

end
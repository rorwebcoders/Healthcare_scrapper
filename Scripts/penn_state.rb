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

url = 'https://residency.med.psu.edu/programs/pulmonary-critical-care-medicine-fellowship/'
browser.goto(url)
# byebug
doc = Nokogiri::HTML(browser.html)
CSV.open("Uthouston_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']

	listings = doc.css('table[@id="DataTables_Table_0"]').css('tr[@role="row"]')[1..-1]
# byebug
	listings.each do |each_list|
		begin
			first_name = each_list.css('td')[1].text rescue ""
			last_name = each_list.css('td')[2].text rescue ""
			suffix = each_list.css('td')[3].text rescue ""
			title = each_list.css('td')[4].text.split(';').join("\n") rescue ""
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
			details_url = each_list.css('td')[5].at('a').attr('href')
			details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
			puts name = details_doc.css('div.doctor-banner').css('h1').text rescue ""
			interest = details_doc.css('div.specialties').text.strip.gsub(/\s+/, " ") rescue ""
			education = details_doc.css('section[@id= "education"]').css('dl').map{|e| e.text.strip}.join("\n") rescue ""
			csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, interest, '','', '', '', education, '', '', '', '']
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
		end
		
	end
end
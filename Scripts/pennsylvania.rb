require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'
require "down"
require "open-uri"

url = 'https://www.pennmedicine.org/departments-and-centers/department-of-medicine/divisions/pulmonology-allergy-and-critical-care/faculty/faculty'

doc = Nokogiri::HTML(RestClient.get(url).body)
CSV.open("Pennsylavania_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']

	listings = doc.css('li.general-list__item.u-cf.general-list__item--with-thumb')
	# byebug
	listings.each do |each_list|
		begin
			details_url = "https://www.pennmedicine.org#{each_list.css('h3.general-list__item-title.h4').css('a').attr('href').value}"
			details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
			puts name = details_doc.css('h1.fad-h1.fad-profile__name').text.strip
			if name.split(',').first.strip.split.count == 2
				first_name = name.split(',').first.strip.split.first rescue ""
				last_name = name.split(',').first.strip.split.last rescue "" rescue ""
			elsif name.split(',').first.strip.split.count == 3
				first_name = name.split(',').first.strip.split[0..1].join(' ') rescue ""
				last_name = name.split(',').first.strip.split.last rescue ""
			elsif name.split(',').first.strip.split.count == 4
				first_name = name.split(',').first.strip.split[0..1].join(' ') rescue ""
				last_name = name.split(',').first.strip.split[2..3].join(' ') rescue ""
			elsif name.split(',').first.strip.split.count == 1
				first_name = name.split(',').first.strip rescue ""
				last_name = ''
			end
			# byebug
			suffix = name.split(",", 2).last.strip rescue ""

			title = details_doc.css('ul.fad-list').css('li')[0..-2].map{|e| e.text.strip}.join("\n")
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
			interest = details_doc.css('ul.fad-detail__terms__list.fad-detail__terms__list--single').css('li').map{|e| e.text.strip}.join("\n") rescue ""
			research = details_doc.css('div.fad-detail__body:contains("Description of Research Expertise")').text.strip rescue ""
			education = details_doc.css('div.fad-detail__terms.fad-l-grid--2col-mq-large.fad-l-grid--2col-mq-medium.fad-u-cf.fad-mb-2.fad-mt-half').text.strip.gsub("\r\n", "").gsub(/\s + /, "\n") rescue ""
			csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, interest, '', '', '', '', research, education, '', '', '', '']
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
		end
		
	end
end
require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://med.nyu.edu/departments-institutes/medicine/divisions/pulmonary-critical-care-sleep-medicine/faculty'

doc = Nokogiri::HTML(RestClient.get(url).body)
CSV.open("Uthouston_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
	listings = doc.css('div.department-leadership__item.js-leadership-item')

	listings.each do |each_list|
		begin
			details_url = each_list.css('a.department-leadership__name-link.js-leadership-link').attr('href').value
			if details_url.start_with?'https://'
				details_url = details_url
			else
				details_url = "https://med.nyu.edu#{details_url}"
			end
			details_doc = Nokogiri::HTML(RestClient.get(details_url))
			puts name = each_list.css('span.department-leadership__name').text
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
			suffix = each_list.css('span.department-leadership__degree').text rescue ""
			title = details_doc.css('ul.academic_departments > li').map{|e| e.text.strip.gsub("\n\t", '').gsub("\t", '')}.join("\n") rescue ""
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
			interest = details_doc.css('li.profile__conditions-and-treatments__list-item').map{|e| e.text.strip}.join("\n") rescue ""
			overview = details_doc.css('div.content > div.richtext').css('p').map{|e| e.text.strip}.join("\n") rescue ""
			research = details_doc.css('div.research').text.strip.gsub("\n            \n                ", "\n") rescue ""
			edu_1 = details_doc.css('div[@id="credentials-content"]').css('div.content-block:contains("Board Certifications")').text.strip.gsub("\t", '') rescue ""
			edu_2 = details_doc.css('div[@id="credentials-content"]').css('div.content-block:contains("Education and Training")').css('li').map{|e| e.text.strip}.join("\n") rescue ""
			education = edu_1.to_s+"\nEducation and Training\n"+edu_2.to_s rescue ""
			csv << [url, details_url, name.split(',').first, first_name, last_name, suffix, title, position_prof, non_prof, interest, '', '', '', overview, research, education, '', '', '', '']
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
		end
		
	end
end
require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://ssom.luc.edu/medicine/divisionsspecialties/pulmonarycriticalcaremedicine/'


doc = Nokogiri::HTML(RestClient.get(url).body)

CSV.open("Loyola_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']

	listings = doc.css('div.col-sm-6.col-md-8')

	listings.each do |each_list|
		begin
			puts name = each_list.css('a > h4').text.strip rescue ""
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
			suffix = name.split(",", 2).last.strip rescue ""
			details_url = each_list.css('a').attr('href').value
			details_doc = Nokogiri::HTML(RestClient.get(details_url))
			interest = details_doc.css('dd.specialties').map{|e| e.text}.join("\n") rescue ""
			title = Nokogiri::HTML(each_list.css('h4').last.to_s.gsub("<br>", "\n")).text rescue ""
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
			education = details_doc.at('dt:contains("Education")').next_element.text.strip.gsub("\r\n\t          \r\n\t","\n") rescue ""
			csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, interest, '', '', '', '', '', education, '', '', '', '']
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
		end
		
	end
end
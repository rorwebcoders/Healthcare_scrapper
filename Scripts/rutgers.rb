require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'
require "down"
require "open-uri"

url = 'https://njms.rutgers.edu/departments/medicine/divisions/pulm/faculty.php'

doc = Nokogiri::HTML(RestClient.get(url).body)
# byebug
CSV.open("Rutgers_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
	listings = doc.css('p.tab')

	listings.each do |each_list|
		begin
			if !each_list.css('a').empty?
				puts details_url = each_list.css('a').attr('href').value
				# byebug
				details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
				puts name = details_doc.css('td[@width="1474"]').css('font[@color="#000066"]').text.strip
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
				title = each_list.to_s.split('<br>').select{|e| Nokogiri::HTML(e).css('a').empty?}.map{|e| Nokogiri::HTML(e).text}.join("\n") rescue ""
				position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
				non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
				email = details_doc.css('a').select{|e| e.to_s.include?'mailto:'}[0].text rescue ""
				overview = Nokogiri::HTML(details_doc.css('div[@id="T3"]').to_s.gsub('<br>',"\n").split('Overview').last.split('<h4>').first).text rescue ""
				education = Nokogiri::HTML(details_doc.css('div[@id="T3"]').to_s.gsub('<br>',"\n").split('Education').last.split('<h4>').first).text rescue ""
				csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, '', email, '', '', overview, '', education, '', '', '', '']
			# else

			end	
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
		end
		
	end
end
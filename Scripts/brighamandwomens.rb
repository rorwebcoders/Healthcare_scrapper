require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'

url = 'https://www.brighamandwomens.org/medicine/pulmonary-and-critical-care-medicine/pulmonary-and-critical-care-team'

doc = Nokogiri::HTML(RestClient.get(url).body)
CSV.open("brighamandwomens_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
	listings = doc.css('div.rich-text.component').css('li')

	listings.each do |each_list|
		begin
			details_url = each_list.at('a').attr('href')
			# listing_title = Nokogiri::HTML(each_list.to_s.gsub('<br>', "\n")).text.gsub(each_list.at('a').text, '').strip rescue ""
			details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
			puts name = details_doc.css('h1[@id= "person_name"]').text.strip rescue ""
			if name.split(',').first.strip.split.count == 2
				first_name = name.split(',').first.strip.split.first
				last_name = name.split(',').first.strip.split.last
			elsif name.split(',').first.strip.split.count == 3
				first_name = name.split(',').first.strip.split[0..1].join(' ')
				last_name = name.split(',').first.split.last.strip
			elsif name.split(',').first.strip.split.count == 4
				first_name = name.split(',').first.strip.split[0..1].join(' ')
				last_name = name.split(',').first.strip.split[2..3].join(' ')
			elsif name.split(',').first.strip.split.count == 1
				first_name = name.split(',').first.strip
				last_name = ''
			end
			suffix = name.split(",", 2).join.split.last.strip rescue ""
			title = details_doc.css('span.specialties_list').map{|e| e.text.strip.chomp(",")}.uniq.join("\n") rescue ""
			# byebug
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n")
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n")
			interests = details_doc.at('div.profileLabel:contains("Clinical Interests")').next_element.css('div').map{|e| e.text.strip.split.map(&:capitalize).join(' ')}.join("\n") rescue ""
			overview = details_doc.css('div[@id="accordion-bio"]').text.strip rescue ""
			education = details_doc.css('div[@id="accordion-education"]').css('div.profileBlockNoBreak').map{|e| e.css('div').map{|e| e.text.strip}.join("\n")}.join("\n\n") rescue ""
			csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, interests, '', '', '', overview, '', education, 'http://directory.ucla.edu/search.php', '', '', '']
		rescue Exception => e
			puts "Exception in #{details_url}\n #{e.message}"
		end
		

	# byebug
	end
end
# puts url


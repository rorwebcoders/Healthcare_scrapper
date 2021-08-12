require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://www.uhhospitals.org/medical-education/medicine/pulmonary-and-critical-care-medical-education/faculty'

doc = Nokogiri::HTML(RestClient.get(url).body)
CSV.open("uhhospitals_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']

	listings = doc.css('div.UH-Inline-Image-Caption-Stacked')

	listings.each do |each_list|
		begin
			puts name = each_list.css('h2').text.strip
			if name.split(',').first.strip.split.count == 2
				first_name = name.split(',').first.strip.split.first
				last_name = name.split(',').first.strip.split.last
			elsif name.split(',').first.strip.split.count == 3
				first_name = name.split(',').first.split.first.strip
				last_name = name.split(',').first.strip.split[1..2].join(' ')
			elsif name.split(',').first.strip.split.count == 4
				first_name = name.split(',').first.strip.split[0..1].join(' ')
				last_name = name.split(',').first.strip.split[2..3].join(' ')
			elsif name.split(',').first.strip.split.count == 1
				first_name = name.split(',').first.strip
				last_name = ''
			end
			suffix = name.split(",", 2).last.strip rescue ""
			title = each_list.css('em').map{|e| e.text.strip}.join("\n") rescue ''
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n")
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n")
			interest = each_list.css('p').text.split('Special Interests:').last.strip rescue ''
			details_url = "https://www.uhhospitals.org#{each_list.at('a').attr('href')}" rescue ''
			# byebug
			overview = ""
			clinical_focus = ""
			if details_url.to_s != ''
				details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
				overview = details_doc.at('h2.UH-Feature-Doctors-DoctorInformation-Heading:contains("Biography")').next_element.text.strip rescue ''
				clinical_focus = details_doc.at('h3.UH-Feature-Doctors-DoctorInformation-Heading:contains("Expertise")').next_element.css('li').map{|e| e.text.strip}.join("\n") rescue ''
				education = details_doc.at('div.UH-Feature-Doctors-DoctorInformation-Section:contains("Education")').css('p').map{|e|e.text.strip}.join.split("\r\n").map{|e| e.gsub(/\s+/, " ").strip}.join("\n") rescue ''
			end
			csv << [url, '', name, first_name, last_name, suffix,title, position_prof, non_prof, interest, '','','', overview, '', education, details_url, clinical_focus,'', '']
		rescue Exception => e
			puts "Exception in #{details_url}\n #{e.message}"
		end
		
	end
end
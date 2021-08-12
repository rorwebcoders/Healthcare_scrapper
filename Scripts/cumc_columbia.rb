require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://www.cumc.columbia.edu/pulmonary/faculty'

doc = Nokogiri::HTML(RestClient.get(url).body)
CSV.open("uhhospitals_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']

	listings = doc.css('ul.facultylist')
	listings.each do |each_list|
		sub_list = each_list.css('li')
		sub_list.each do |each_data|
			begin
				details_url = "https://www.cumc.columbia.edu#{each_data.css('a').attr('href').value}"
				details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
				puts name = details_doc.css('h1.headline').text.strip rescue ''
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
				suffix = name.split(",", 2).last.strip rescue ""
				title = details_doc.css('div.field-field-academic-title').text.strip rescue ''
				# byebug
				position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n")
				non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n")
				interest = details_doc.at('h2:contains("Specialties")').next_element.css('li').map{|e| e.text.strip}.join("\n") rescue ''
				overview = details_doc.css('div.field-field-bio-detail').css('p').text rescue ''
				research = details_doc.at('h2:contains("Research Interests")').next_element.css('li').map{|e| e.text.strip}.join("\n") rescue ''
				education = details_doc.css('dl.educationlist').text.strip rescue ''
				awards = details_doc.at('h2:contains("Selected Honors and Awards")').next_element.css('li').map{|e| e.text.strip}.join("\n") rescue ''
				csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, interest, '', '', '', overview, research, education, '', '', awards, '']
			rescue Exception => e
				puts "Exception in #{details_url}\n #{e.message}"
			end
		end
	end
end
require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://keck.usc.edu/pulmonary-critical-care-sleep-division/faculty/'

doc = Nokogiri::HTML(RestClient.get(url).body)
listings = doc.css("div[class*=mix]")
CSV.open("Indiana_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
	listings.each do |each_list|
		details_url = each_list.css('a').attr('href').value.gsub('./', 'https://keck.usc.edu/pulmonary-critical-care-sleep-division/faculty/')
		details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
		puts name = each_list.css('a').text.strip 
		# puts name = details_doc.css('div.faculty-header').css('h2').text.strip rescue ""
		if name.split(',').first.strip.split.count == 2
			first_name = name.split(',').first.strip.split.first rescue ""
			last_name = name.split(',').first.strip.split.last rescue ""
		elsif name.split(',').first.strip.split.count == 3
			first_name = name.split(',').first.strip.split[0..1].join(' ') rescue ""
			last_name = name.split(',').first.split.last.strip rescue ""
		elsif name.split(',').first.strip.split.count == 4
			first_name = name.split(',').first.strip.split[0..1].join(' ') rescue ""
			last_name = name.split(',').first.strip.split[2..3].join(' ') rescue ""
		elsif name.split(',').first.strip.split.count == 1
			first_name = name.split(',').first.strip rescue ""
			last_name = ''
		end
		suffix = name.split(",", 2).last.strip rescue ""
		title = details_doc.css('div.c-profile__clinic').text rescue ""
		position_prof = title.split(";").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
		non_prof = title.split(";").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
		email = details_doc.css('div.c-contact__items:contains("@")').text.strip rescue ""
		overview = details_doc.css('div[@id="overviewTab"]').text.strip rescue ""
		awards = details_doc.css('div.awards-content').css('p').map{|e| e.text.strip}.join("\n") rescue ""
		csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, '', email, '','', overview, '', '', '', '', awards, '']
	end
end
byebug

puts url
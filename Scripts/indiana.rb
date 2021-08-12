require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://medicine.iu.edu/internal-medicine/specialties/pulmonary/faculty'
CSV.open("Indiana_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']

	doc = Nokogiri::HTML(RestClient.get(url).body)
	listings = doc.css('div.rvt-grid__item-6-md-up')
	listings.each do |each_list|
		details_url = "https://medicine.iu.edu#{each_list.css('h2 > a').attr('href').value}"
		details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
		puts name = details_doc.css('div.faculty-header').css('h2').text.strip rescue ""
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
		# byebug
		suffix = name.split(",", 2).last.strip rescue ""
		title = details_doc.at('h2:contains("Titles & Appointments")').next_element.css('li').map{|e| e.text}.join("\n") rescue ""
		position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
		non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
		education = details_doc.at('div.accordion-header:contains("Education")').next_element.css('div.item').map {|e| e.css('span').map{|x| x.text+ ' '}.join}.join("\n") rescue ""
		awards = details_doc.at('div.accordion-header:contains("Awards")').next_element.css('div.item').text.strip.gsub("\r\n", "\n") rescue ""
		csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, '', '', '', '', '', '', education, '', '', awards, '']
	end
end
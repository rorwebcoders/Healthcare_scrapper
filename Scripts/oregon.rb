require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://www.ohsu.edu/school-of-medicine/pulmonary-critical-care-medicine/faculty'

doc = Nokogiri::HTML(RestClient.get(url).body)
CSV.open("Oregon_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']

	listings = doc.css('section.image-with-text.image-with-text--left-aligned')

	listings.each do |each_list|
		begin
			puts name = each_list.css('p')[0].text.strip
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
			title = each_list.css('p')[1..-2].map{|e| e.text.strip}.join("\n") rescue ""
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
			overview = each_list.css('p').last.text.strip rescue ""
			csv << [url, '', name, first_name, last_name, suffix, title, position_prof, non_prof, '', '', '', '', overview, '', '', '', '', '', '']
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
		end
		
	end
end
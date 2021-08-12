require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'


url = 'https://med.uth.edu/internalmedicine/pulmonary-and-sleep-medicine/faculty/'
doc = Nokogiri::HTML(RestClient.get(url).body)
CSV.open("Uthouston_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
	listings = doc.css('li.facultylist-item.col-3')

	listings.each do |each_list|
		begin
			details_url = each_list.css('div.fl-info').css('a').attr('href').value
			details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
			puts name = details_doc.css('div.col-md-12 > h1').text.strip rescue ""
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
			title = details_doc.css('div[@id="bio-card"]').css('div.col-md-4')[0].text.strip.split('|').join("\n") rescue ""
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
			interest =  details_doc.css('div[@id="bio-card"]').css('div.col-md-4')[1].css('li').map{|e| e.text.strip}.join("\n") rescue ""
			research = details_doc.css('div[@id="areas_interests"]').css('li').map{|e| e.text.strip}.join("\n") rescue ""
			email = details_doc.at('span.fa.fa-envelope-o').next_element.attr('href').split(':').last rescue ""
			overview = details_doc.css('div[@id= "bio"]').css('p').map{|e| e.text.strip}.join("\n") rescue ""
			education = details_doc.at('h3:contains("Education")').next_element.text.strip.gsub("\t", '') rescue ""
			csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, interest, email, '', '', overview, research, education, '','','','']
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
		end
		
		# byebug
	end
end
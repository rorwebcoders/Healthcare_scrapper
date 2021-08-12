require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://www.rushu.rush.edu/education-and-training/faculty?field_program_tid=425'

doc = Nokogiri::HTML(RestClient.get(url).body)
CSV.open("Uthouston_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
	listings = doc.css('div.grid__item.grid__item--3')

	listings.each do |each_list|
		begin
			details_url = "https://www.rushu.rush.edu#{each_list.css('div.feed__title > a').attr('href').value}"
			details_doc = Nokogiri::HTML(RestClient.get(details_url))
			puts name = each_list.css('div.feed__title').text.strip
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
			tit = details_doc.css('div.job-titles').text.strip rescue ""
			tit_1 = details_doc.css('div.primary').text.strip.gsub(/\s+/, " ") rescue ""
			tit_2 = details_doc.css('div.departments').text.strip rescue ""
			title = tit.to_s+"\n"+tit_1.to_s+"\n"+tit_2.to_s rescue ""
			position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
			non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
			puts email = details_doc.css('a').select{|e| e.to_s.include?'mailto:'}[0].attr('href') rescue ""
			research = Nokogiri::HTML(details_doc.css('div.section__main.print-only').to_s.split('Research Areas').last).css('p').map{|e| e.text.strip}.join("\n") rescue ""
			education = Nokogiri::HTML(details_doc.css('div.section__main.print-only').to_s.split('Education').last.split('<h6>').first).css('p').map{|e| e.text.strip}.join("\n") rescue ""
			csv << [url, details_url, name, first_name, last_name,suffix, title, position_prof, non_prof, '', email, '', '', '', research, education, '', '', '', '']
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
		end
		

	end
end
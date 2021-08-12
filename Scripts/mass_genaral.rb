require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = 'https://www.pulmonaryfellowship.hms.harvard.edu/faculty'

doc = Nokogiri::HTML(RestClient.get(url).body)

listings = doc.css('div.col.sqs-col-3.span-3')
CSV.open("Mass_general_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
	listings.each do |each_list|
		begin
			details_url_val = each_list.css('h2').css('a').attr('href').value
			# byebug
			if details_url_val.start_with?'https://connects.catalyst.harvard.edu'
				details_url = details_url_val
				puts name = each_list.css('h2').css('a').text.strip
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
				suffix = name.split(",", 2).join.split.last.strip rescue ""
				title = each_list.css('p').map{|e| e.text.strip}.join("\n") rescue ""
				position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
				non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
				csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, '', '', '','', '', '', '', '', '', '', '' ]
			else
				details_url = "https://www.pulmonaryfellowship.hms.harvard.edu#{each_list.css('h2').css('a').attr('href').value}"
				
				puts details_url
				details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
				puts name = each_list.css('h2').css('a').text.strip
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
				suffix = name.split(",", 2).join.split.last.strip rescue ""
				title = details_doc.css('div.row.sqs-row')[0].css('div.sqs-block-content')[1].css('h2').map{|e| e.text.strip}.join("\n") rescue ""
				position_prof = title.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
				non_prof = title.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
				overview = details_doc.css('div.sqs-block-content:contains("Academic Interests")').css('p').map{|e| e.text.strip}.join("\n\n") rescue ""
				add_url = details_doc.css('div.row.sqs-row')[0].css('p > a').attr('href').value rescue ""
				awards = details_doc.css('div.sqs-block-content:contains("Awards and Recognition")').css('p').select{|e| e.css('a').empty?}.map{|e| e.text.strip}.join("\n\n") rescue ""
				csv << [url, details_url, name, first_name, last_name, suffix, title, position_prof, non_prof, '', '', awards,'', overview, '', '', add_url, '', '', '' ]
			end
		rescue Exception => e
			puts "Exception in #{details_url}\n #{e.message}"
		end
		
	end
end

# byebug
puts url
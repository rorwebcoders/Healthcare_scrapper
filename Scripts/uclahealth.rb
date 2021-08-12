require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = "https://www.uclahealth.org/pulmonary/our-team"

doc = Nokogiri::HTML(RestClient.get(url).body)

CSV.open("uclahealth_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']

	listings = doc.css('div.col-sm-12.col-md-6')
	listings.each do |each_list|
		begin
			details_url = each_list.css('a').attr('href').value
			if !details_url.include? 'https://'
				details_url = "https://www.uclahealth.org/pulmonary/"+each_list.css('a').attr('href').value
			end
			details_doc = Nokogiri::HTML(RestClient.get(details_url))
			first_name = ''
			last_name = ''
			# listing_title = each_list.css('p')[1].text rescue ""
			name = each_list.css('a').text.strip
			puts details_name = details_doc.css('h2.font-serif.font-normal.text-white').text.strip rescue ""
			if details_name.to_s != ''
				if details_name.split(',').first.strip.split.count == 2
					first_name = details_name.split(',').first.strip.split.first
					last_name = details_name.split(',').first.strip.split.last
				elsif details_name.split(',').first.strip.split.count == 3
					first_name = details_name.split(',').first.strip.split[0..1].join(' ')
					last_name = details_name.split(',').first.strip.split.last
				elsif details_name.split(',').first.strip.split.count == 4
					first_name = details_name.split(',').first.strip.split[0..1].join(' ')
					last_name = details_name.split(',').first.strip.split[2..3].join(' ')
				elsif details_name.split(',').first.strip.split.count == 1
					first_name = details_name.split(',').first.strip
					last_name = ''
				end
				suffix = name.split(",", 2).last.strip rescue ""
				details_title = each_list.css('div.col-xs-8.col-sm-8').css('p').last.text rescue ""
				position_prof = details_title.split(',').select{|e| e.downcase.include? 'professor'}.join("\n")
				non_prof = details_title.split(',').select{|e| !e.downcase.include? 'professor'}.join("\n")
				interest = details_doc.css('div.flex.items-center.mt-1').text.strip.gsub(/\s+/, ' ') rescue ""
				education = details_doc.css('div.mt-16:contains("Education")').text.split('Education').last.strip rescue ""
				research = details_doc.css('div.mt-16:contains("Research")').css('li').map{|e| e.text.strip}.join("\n") rescue ""
				csv << [url, details_url, name, first_name, last_name, suffix, details_title, position_prof, non_prof, interest, '', '', '', '', '',  research, education, 'http://directory.ucla.edu/search.php', '', '', '']
			else
				csv << [url, details_url, name, first_name, last_name, suffix, '', '', '', '', '', '', '', '', '',  '', '', 'http://directory.ucla.edu/search.php', '', '', '']
			end
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
			puts e.backtrace
			# byebug
		end
		
	end
end

# byebug
puts url
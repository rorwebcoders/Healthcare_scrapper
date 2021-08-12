require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'

url = "https://www.utsouthwestern.edu/education/medical-school/departments/internal-medicine/divisions/pulmonary-critical-care/faculty.html"

doc = Nokogiri::HTML(RestClient.get(url).body)

listings = doc.css('div.figure.left.small-w40.medium-w25.large-w25')

CSV.open("utsouthwestern_data_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
	listings.each do |each_list|
		begin
			details_url = each_list.next_element.at('a').attr('href').gsub('http:','https:')+each_list.next_element.at('a').text.strip.split(',').first.downcase.gsub(' ', '-').gsub('"','')+'.html'
			# details_url = "https://profiles.utsouthwestern.edu/profile/109365/john-battaile.html"
			each_list.next_element.css('a').remove
			listing_title = Nokogiri::HTML(each_list.next_element.to_s.split('<br>').join("\n")).text.strip rescue ""
			details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
			# details_title = details_doc.css('small[@itemprop="jobTitle"]').map {|e| e.text.strip}.join("\n")	rescue ""
			position_prof = Nokogiri::HTML(each_list.next_element.to_s.split('<br>').join("\n")).text.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n")
			non_prof = Nokogiri::HTML(each_list.next_element.to_s.split('<br>').join("\n")).text.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n")
			puts name = Nokogiri::HTML(details_doc.css('h1').to_s.split('<br>').first).text.strip
			if name.split(',').first.strip.split.count == 2
				first_name = name.split(',').first.strip.split.first
				last_name = name.split(',').first.strip.split.last
			elsif name.split(',').first.strip.split.count == 3
				first_name = name.split(',').first.strip.split[0..1].join(' ')
				last_name = name.split(',').first.strip.split.last
			elsif name.split(',').first.strip.split.count == 4
				first_name = name.split(',').first.strip.split[0..1].join(' ')
				last_name = name.split(',').first.strip.split[2..3].join(' ')
			elsif name.split(',').first.strip.split.count == 1
				first_name = name.split(',').first.strip
				last_name = ''
			end
			suffix = name.split(',').last rescue ""
			research = details_doc.css('div[@id= "researchTitle"]').css('li').map{|e| e.text.strip}.join("\n") rescue ""
			education = details_doc.css('div[@id="educationTitle"]').text.strip rescue ""
			additional_url = details_doc.css('div.academic-profile-user-warning').css('a.button.small.mt1').attr('href').value rescue ""
			# byebug
			if additional_url.to_s != ''
				add_doc = Nokogiri::HTML(RestClient.get(additional_url).body)
				clinical_focus = add_doc.at('h2:contains("Clinical Focus")').next_element.css('li').map{|e| e.text.strip}.join("\n") rescue ""
			end
			csv << [url, details_url, name, first_name, last_name, suffix, listing_title, position_prof, non_prof, '', '', '', '', '', research, education, additional_url, clinical_focus, '', '']
		rescue Exception => e
			puts "exception in #{details_url}\n #{e.message}"
		end
		
	end
end
puts url
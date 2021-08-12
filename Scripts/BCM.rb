require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

url = "https://www.bcm.edu/departments/medicine/sections-and-divisions/section-of-pulmonary-critical-care-and-sleep-medicine/faculty"
listing_page = Nokogiri::HTML(open(url))

CSV.open("Output/BCM.csv", "w", {:col_sep => ","}) do |csv|
	csv << ["Detail Url", "Name", "First Name", "Last Name", "Suffix", "Title/Positions/Academic Appointments", "Position Professor", "Position Non Professor", "Interest/Subspecialty", "email1", "email2", "email3", "overview", "research", "education/training/boards", "Additional  Url", "Clinical Focus", "Awards/Pubs", "Other positions"]
	
	listing_page.css("article[typeof='schema:Person']").each do |faculty|
		# next unless faculty.css(".field--name-field-first-name .field--item").text.include? "Ritwi"
		splitted_names = [faculty.css(".field--name-field-first-name .field--item").text]
		splitted_names << faculty.css(".field--name-field-middle-name .field--item").text unless faculty.css(".field--name-field-middle-name .field--item").text==""
		splitted_names << faculty.css(".field--name-field-last-name .field--item").text unless faculty.css(".field--name-field-last-name .field--item").text==""
		
		first_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[0]&.join(" ")
		last_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[1]&.join(" ")
		suffix = faculty.css(".field--name-field-honorific-title .field--item").text
				
		puts name = splitted_names.join(" ") + ", #{suffix}"		
		position = faculty.css(".field--name-field-position .field--item").text
		professor_position = position.match(/professor/i) ? position : ""
		non_professor_position = position.match(/professor/i) ? "" : position 
		detail_url = "https://www.bcm.edu" + faculty.css("a").attr("href").text
		
		additional_page = Nokogiri::HTML(open(detail_url))
		# here there is a prblm, it is taking all following siblings
		
		unless additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Positions')").text==""
			position = []
			professor_position = []
			non_professor_position = []
			splitted_position_1 = additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Positions')").first.xpath("following-sibling::dl").map{|x| [x.css("dt").text, x]} 
			
			unless additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Positions')").first.xpath("following-sibling::h3").empty?
				splitted_position_2 = additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Positions')").first.xpath("following-sibling::h3").first.xpath("preceding-sibling::dl").map{|x| x.css("dt").text}
			else
				splitted_position_2 = splitted_position_1.map{|x| x.first}
			end
			
			splitted_position_1.select{|x| (splitted_position_1.map(&:first) & splitted_position_2).include? x[0]}.each do |pos|
				position << pos[0] + "\n" + pos[1].css("dd").to_s.gsub(/<.*?>/, "\n").strip.split("\n").map{|x| x.strip}.join("\n")
				professor_position << pos[0] + "\n" + pos[1].css("dd").to_s.gsub(/<.*?>/, "\n").strip.split("\n").map{|x| x.strip}.join("\n") if pos[0].match(/professor/i)
				non_professor_position << pos[0] + "\n" + pos[1].css("dd").to_s.gsub(/<.*?>/, "\n").strip.split("\n").map{|x| x.strip}.join("\n") unless pos[0].match(/professor/i)
			end
		end
		
		# position = additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Positions')").first.xpath("following-sibling::dl").map{|x| x.css("dt").text}.join("\n")
		email = additional_page.css("article[typeof='schema:Person'] a[href^='mailto']").text
		education = []
		unless additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Education')").text==""
			education_1 = additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Education')").first&.xpath("following-sibling::dl")&.map{|x| [x.css("dt").text, x]}
			education_2 = additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Education')").first&.xpath("following-sibling::h3")&.first&.xpath("preceding-sibling::dl")&.map{|x| x.css("dt").text}
			education_2 = education_1.map{|x| x.first} if education_2.nil? and !education_1.nil?
			
			education_1.select{|x| (education_1.map(&:first) & education_2).include? x[0]}.each do |edu|
				education << edu[0] + "\n" + edu[1].css("dd").to_s.gsub(/<.*?>/, "\n").strip.split("\n").reject{|x| x.strip==""}.map{|x| x.strip}.join("\n")			
			end
		end
		
		intrests = additional_page.css("article[typeof='schema:Person'] h3.user--details:contains('Professional Interests')").first&.next_element&.css("li")&.map{|x| x.text.strip}&.join("\n")
		
		
		csv << [detail_url, name, first_name, last_name, suffix, position.join("\n\n"), professor_position.join("\n\n"), non_professor_position.join("\n\n"), intrests, email, "", "", "", "", education.join("\n\n"), "", "", "", ""]
	end
end



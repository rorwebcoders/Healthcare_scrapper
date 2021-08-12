require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

url = "https://www.bumc.bu.edu/pulmonarycenter/definition/meet-our-team/faculty-2/"
listing_page = Nokogiri::HTML(open(url))

CSV.open("Output/BUMC.csv", "w", {:col_sep => ","}) do |csv|
	csv << ["Detail Url", "Name", "First Name", "Last Name", "Suffix", "Title/Positions/Academic Appointments", "Position Professor", "Position Non Professor", "Interest/Subspecialty", "email1", "email2", "email3", "overview", "research", "education/training/boards", "Additional  Url", "Clinical Focus", "Awards/Pubs", "Other positions"]
	
	listing_page.css("table td").each_with_index do |faculty, index|
		detail_url = faculty.css("a")&.attr("href")&.text
		unless detail_url.nil?
			name = faculty.css("a").text
		else
			name = faculty.css("p").text
		end
		splitted_names = name.split(", ")[0].split(" ")
		first_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[0].join(" ")
		last_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[1].join(" ")
		suffix = name.split(", ")[1..-1].join(", ")
		puts "#{index}) #{name}"
		
		begin 			
			if detail_url.include? "www.bumc.bu"
				# next
				additional_page = Nokogiri::HTML(open(detail_url))
				# position = additional_page.css("h4.profile-position").map{|x| x.text.strip}.join("\n")
				splitted_positions = additional_page.css("h4.profile-position").map{|x| x.text.strip}
				position = splitted_positions.join("\n")
				professor_position = splitted_positions.select{|x| x.match(/professor/i)}.join("\n")
				non_professor_position = splitted_positions.select{|x| !x.match(/professor/i)}.join("\n")
				
				email = additional_page.css("p.email").map{|x| x.text.strip}.join("\n")
				overview = additional_page.css("div.profile-single-bio p").map{|x| x.text.strip}.join("\n")
				education = additional_page.css("div.profile-single-education p").map{|x| x.text.strip}.join("\n")
				other_position = additional_page.css("div.profile-single-other-positions p").map{|x| x.text.strip}.join("\n")
			elsif detail_url.include? "www.bu.edu"
				additional_page = Nokogiri::HTML(open(detail_url))
				education = additional_page.css("p:has(strong:contains('Degrees and Positions'))").first.next_element.css("li").map{|x| x.text.strip}.join("\n")
				email = additional_page.css("a[href^='mailto']").text
			end
		rescue 
		end
		csv << [detail_url, name, first_name, last_name, suffix, position, professor_position, non_professor_position, "", email, "", "", overview, "", education, "", "", "", other_position]
	end
	
end

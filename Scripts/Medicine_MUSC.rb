require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'

url = "https://medicine.musc.edu/departments/dom/divisions/pulmonary-and-critical-care/faculty"
listing_page = Nokogiri::HTML(open(url))

CSV.open("Output/Medicine_MUSC1.csv", "w", {:col_sep => ","}) do |csv|
	csv << ["Detail Url", "Name", "First Name", "Last Name", "Suffix", "Title/Positions/Academic Appointments", "Position Professor", "Position Non Professor", "Interest/Subspecialty", "email1", "email2", "email3", "overview", "research", "education/training/boards", "Additional  Url", "Clinical Focus", "Awards/Pubs", "Other positions"]
	listing_page.css("#main .staff-grid").each_with_index do |staff, index|

		staff_name = staff.css("a").text()
		staff_name = staff.css("h3").text() if staff_name==""
		splitted_names = staff_name.split(", ")[0].split(" ")
		first_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[0].join(" ")
		last_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[1].join(" ")
		suffix = staff_name.split(", ")[1..-1].join(", ")
		staff_link = staff.css("a").attr("href")&.text()
		position = staff.css("h3").first.next_element.text().split("\n").join(" ")
		professor_position = [position].select{|x| x.match(/professor/i)}.join(" ")
		non_professor_position = [position].select{|x| !x.match(/professor/i)}.join(" ")
		puts "#{index}) #{staff_name} -- #{staff_link}"
		
		unless staff_link.nil?
			# next unless index==16
			faculty_page = Nokogiri::HTML(open(staff_link))
			
			unless staff_link.split("/").include? "ProviderDirectory"
				splitted_positions = faculty_page.css("#BasicInfo h5:contains('Rank')").first().next_element.css("li").map{|x| x.text().strip}
				position = splitted_positions.join(", ")
				professor_position = splitted_positions.select{|x| x.match(/professor/i)}.join(" ")
				non_professor_position = splitted_positions.select{|x| !x.match(/professor/i)}.join(" ")
				intrest = faculty_page.css("#BasicInfo h5:contains('Academic Focus')").first()&.next_element&.css("li")&.map{|x| x.text().strip}&.join(", ")
				email = faculty_page.css("#BasicInfo div.profileLinks p.myChart").text().strip
				overview = faculty_page.css("#BasicInfo div.bio p").map{|x| x.text().strip}.join('\n')
				additional_info_link = faculty_page.css("#BasicInfo .left-profile:has(div.profileLinks) > ul a:not(.hidden)")&.attr('href')&.text()
			else
				additional_info_link = ""
				additional_info = faculty_page
			end
			
			education = clinical_focus = ""
			unless additional_info_link.nil?
				additional_info = Nokogiri::HTML(open(additional_info_link)) unless staff_link.split("/").include? "ProviderDirectory"
				education = additional_info.css("table.ProviderProfileBasicInfo").map{|e| e.css('td').map{|e| e.css('span').map{|e| e.text.strip}}}.join("\n").strip.split('Specialties').first
				# byebug
				clinical_focus = "Specialties:\n" + additional_info.css("table.ProviderProfileBasicInfo tr:has(span:contains('Specialties')) .ProviderProfileListItems li").map{|x| x.text().strip}.join("\n")
			end
			
			csv << ["", staff_name, first_name, last_name, suffix, position, professor_position, non_professor_position, intrest, email, "", "", overview, "", education, additional_info_link, clinical_focus, "", ""]
		else			
			csv << ["", staff_name, first_name, last_name, suffix, position, professor_position, non_professor_position, "", "", "", "", "", "", "", "", "", "", ""]
		end

	end
end

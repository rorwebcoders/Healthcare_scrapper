require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

url = "https://einsteinmed.org/departments/medicine/divisions/pulmonary-medicine/faculty/"
listing_page = Nokogiri::HTML(open(url))

CSV.open("Output/EinsteinMed.csv", "w", {:col_sep => ","}) do |csv|
	csv << ["Detail Url", "Name", "First Name", "Last Name", "Suffix", "Title/Positions/Academic Appointments", "Position Professor", "Position Non Professor", "Interest/Subspecialty", "email1", "email2", "email3", "overview", "research", "education/training/boards", "Additional  Url", "Clinical Focus", "Awards/Pubs", "Other positions"]
	
	listing_page.css("#contentFullWidth div.item").each_with_index do |faculty, index|
		name = faculty.css("h4 a").text()
		# splitted_names = name.split(", ")[0].split(" ")
		# first_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[0].join(" ")
		# last_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[1].join(" ")
		if name.split(',').first.strip.split.count == 2
				first_name = name.split(',').first.strip.split.first
				last_name = name.split(',').first.strip.split.last
			elsif name.split(',').first.strip.split.count == 3
				first_name = name.split(',').first.strip.split[0..1].join(' ')
				last_name = name.split(',').first.split.last.strip
			elsif name.split(',').first.strip.split.count == 4
				first_name = name.split(',').first.strip.split[0..1].join(' ')
				last_name = name.split(',').first.strip.split[2..3].join(' ')
			elsif name.split(',').first.strip.split.count == 1
				first_name = name.split(',').first.strip
				last_name = ''
			end
		suffix = name.split(", ")[1..-1].join(", ")
		puts "#{index}) #{name}"
		detail_url = "https://einsteinmed.org" + faculty.css("h4 a").attr("href").text
		detail_page = Nokogiri::HTML(open(detail_url))
		splitted_positions = detail_page.css('div.faculty-titles > p').map{|e| e.text.strip}.join("\n")
		# position = splitted_positions.join("\n")
		professor_position = splitted_positions.split("\n").select{|x| x.match(/professor/i)}.join("\n")
		non_professor_position = splitted_positions.split("\n").select{|x| !x.match(/professor/i)}.join("\n")
		email = faculty.css("div.contact a").text()
		overview = detail_page.css("div.large-type.content").map{|x| x.text}.join("\n")
		
		# research part is pending
		csv << [detail_url, name, first_name, last_name, suffix, splitted_positions, professor_position, non_professor_position, "", email, "", "", overview, "", "", "", "", "", ""]
	end
end

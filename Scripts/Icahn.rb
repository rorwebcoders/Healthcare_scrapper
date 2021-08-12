require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'json'
require 'watir'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

url = "https://icahn.mssm.edu/about/departments/medicine/pulmonary/faculty"
listing_page = Nokogiri::HTML(open(url))

CSV.open("Output/Icahn.csv", "w", {:col_sep => ","}) do |csv|
	csv << ["Detail Url", "Name", "First Name", "Last Name", "Suffix", "Title/Positions/Academic Appointments", "Position Professor", "Position Non Professor", "Interest/Subspecialty", "email1", "email2", "email3", "overview", "research", "education/training/boards", "Additional  Url", "Clinical Focus", "Awards/Pubs", "Other positions"]
	
	# listing_page.css("div.sqs-row div.html-block").each_with_index do |faculty, index|
		
	# end
	data = listing_page.css('script[type="text/javascript"]:contains("window.people")').text.match(/.*window.people = (.*?}\]\;).*/).captures[0][0..-2]
	json = JSON.parse(data)
	json.each_with_index do |faculty, index|
		detail_url = "https://icahn.mssm.edu/profiles/" + faculty["furl"]
		
		detail_page = Nokogiri::HTML(open(detail_url))
		
		name = detail_page.css("div.bio-content h1").text
		splitted_names = name.split(", ")[0].split(" ")
		first_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[0].join(" ")
		last_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[1].join(" ")
		suffix = name.split(", ")[1..-1].join(", ")
		puts "#{index}) #{name}"
		splitted_positions = detail_page.css("div.bio-content .bio-degree li").map{|x| x.text}
		position = splitted_positions.join("\n")
		professor_position = splitted_positions.select{|x| x.match(/professor/i)}.join("\n")
		non_professor_position = splitted_positions.select{|x| !x.match(/professor/i)}.join("\n")
		intrest = detail_page.css("div.bio-content .bio-specialty span").text
		overview = detail_page.css("#collapsebio > div > :first-child").css("p").text
		if overview.to_s == ''
			# byebug
			overview = detail_page.css("#collapsebio > div").css('p')[1].text.strip rescue ''
		end
		email = ''
		add_url = ''
		email = detail_page.css('ul.bio-contact.list-inline').css('a').attr('href').value.gsub('mailto:', '') rescue ''
		if email.to_s != ''
			add_url = "https://mail.google.com/mail/u/0/?fs=1&tf=cm&source=mailto&to=#{email}"
		end
		# byebug
		education = (faculty["certifications"] || []).join("\n") + "\n\n"
		
		education_title = detail_page.css("h3:contains('Education')").first
		loop do 
			break if education_title.nil? or education_title.next_element.nil? or education_title.next_element.name != "p"
			education.concat(education_title.next_element.text + "\n")
			education_title = education_title.next_element
		end
		
		csv << [detail_url, name, first_name, last_name, suffix, position, professor_position, non_professor_position, intrest, email, "", "", overview, "", education, add_url, "", "", ""]
	end
end


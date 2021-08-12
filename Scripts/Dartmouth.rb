require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'json'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

url = "https://www.dartmouth-hitchcock.org/pulmonology/pulmonary-medicine-team"
listing_page = Nokogiri::HTML(open(url))

CSV.open("Output/Dartmouth.csv", "w", {:col_sep => ","}) do |csv|
	csv << ["Detail Url", "Name", "First Name", "Last Name", "Suffix", "Title/Positions/Academic Appointments", "Position Professor", "Position Non Professor", "Interest/Subspecialty", "email1", "email2", "email3", "overview", "research", "education/training/boards", "Additional  Url", "Clinical Focus", "Awards/Pubs", "Other positions"]
	
	listing_page.css("div.fap__provider-summary").each_with_index do |faculty, index|
		name = faculty.css(".media__body h2").text
		puts "#{index}) #{name}"
		splitted_names = name.split(", ")[0].split(" ")
		first_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[0].join(" ")
		last_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[1].join(" ")
		suffix = name.split(", ")[1..-1].join(", ")
		# intrest = faculty.css("h4:contains('Areas of focus')").first.next_element.css("li").map{|x| x.text}
		
		# next unless first_name == "Alix"
		detail_url = "https://www.dartmouth-hitchcock.org" + faculty.css(".media__body h2 a").attr("href").text
		json = JSON.parse(open("https://www.dartmouth-hitchcock.org/findaprovider/data/GetProvider/#{detail_url.split('/')[-2]}").read)
		# json = JSON.parse(open("https://www.dartmouth-hitchcock.org/findaprovider/data/GetProvider/1126").read)
		profile_data = json["reply"]["result"]["GetProfileResponse"]["GetProfileResult"]
		intrest = profile_data["AreasOfFocus"]
		awards = begin profile_data["Awards"]["Award"]["Title"] rescue "" end
		position = begin profile_data["ProviderTitles"]["ProviderTitle"]['Title'] rescue "" end
			if position.to_s == ''
				position = begin profile_data["ProviderTitles"]["ProviderTitle"].map {|e| e["Title"]}.join("\n") rescue "" end
			end
			# byebug
		professor_position = position.split("\n").select{|e| e.downcase.include? 'professor'}.join("\n") rescue ""
		non_professor_position = position.split("\n").select{|e| !e.downcase.include? 'professor'}.join("\n") rescue ""
		
		education = ""
		profile_data["Educations"]["Educations"].group_by{|x| x["Type"]}.each do |key, val|
			education.concat(key + ":\n")			
			val.each do |ev|
				instution = []
				instution << ev["ProfessionalSuffix"] unless ev["ProfessionalSuffix"].nil?
				instution << ev["Field"] unless ev["Field"].nil?
				unless ev["InstitutionName"].nil?
					instution << ev["InstitutionName"]["Name"] unless ev["InstitutionName"]["Name"].nil?
					instution << ev["InstitutionName"]["Location"] unless ev["InstitutionName"]["Location"].nil?
				end
				instution << ev["YearCompleted"]
				education.concat(instution.join(", ")+"\n")
			end
			education.concat("\n")
		end
		
		email_json = JSON.parse(open("https://api-lookup.dartmouth.edu/v1/lookup?q=#{name.sub(', '+suffix, '')}&includeAlum=false&field=mail").read)
		email = email_json["users"].length > 0 ? email_json["users"].first["mail"] : ""
		
		csv << [detail_url, name, first_name, last_name, suffix, position, professor_position, non_professor_position, intrest, email, "", "", "", "", education, "", "", awards, ""]
	end
end



# -*- encoding : utf-8 -*-
require 'csv'
require 'nokogiri'
require 'open-uri'
require 'mysql2'
require 'openssl'
require 'json'
require 'byebug'
require 'final_redirect_url'

csv  = CSV.open("sample_uab_data.csv", 'wb')
csv << ['Exact URL', 'Detail URL', 'Name', 'First  Name', 'Last  Name', 'Suffix', 'Title/Positions/Academic Appointments', 'Position  Professor', 'Position Non Professor', 'Interest/Subspecialty', 'email1', 'email2', 'email3', 'overview', 'research', 'education/training', 'Additional  Url', 'Clinical Focus', 'Awards', 'Other positions']
          @i = 1
        @num = 160
        
	while @i < @num  do
		url = "https://www.uab.edu/medicine/pulmonary/faculty?start=#{@i}"
		doc1 = Nokogiri::HTML(open(url))
		temp_1 =  doc1.css("ul.category.list-striped li")
			temp_1.each do |t_1|
				 title = t_1.css("h3").text.strip()
				  detail_url = "https://www.uab.edu"+t_1.css("h3 a")[0]["href"]
				  area_of_interest = t_1.at("p:contains('Areas of Interest')").text.gsub("Areas of Interest:"," ").gsub("Areas of Interest"," ").gsub("  "," ").strip()
				if title.to_s.include?(",")
					  l_name =  title.split(",").first.strip()
					  f_name = title.split(",")[1].strip()
				else
					  l_name =  title.split(" ").first.strip()
					  f_name = title.split(" ")[1].strip()
					 "---------	"
				end
				full_name = title
				suffix = title.split(',').last
			f_detail_url =  FinalRedirectUrl.final_redirect_url(detail_url)
			 f_detail_url
				doc = Nokogiri::HTML(open(f_detail_url))

				temp_2 = doc.css("ul#primary-email li")
				
				em_tem = []
				temp_2.each  do |t_2|
					 em_tem << t_2.css("a")[0]["href"].gsub("mailto:","").strip() rescue ""
				end
				 
				 # em_tem.uniq
				  email_1 = em_tem.uniq[0]
				  email_2 = em_tem.uniq[1]
				   email_3 = em_tem.uniq[2]
 phone1 = doc.css("ul#individual-phone li")[0].text.strip() rescue ""
 phone2 = doc.css("ul#individual-phone li")[1].text.strip() rescue ""

positions = []
	 temp_3 = doc.css("ul#individual-personInPosition li")
	temp_3.each do |t_3|
		 positions << t_3.text.strip().gsub("\n"," ").gsub("  "," ").strip()  rescue ""
	end
	position_prof = positions.select{|e| e.downcase.include? 'professor'}.join("\n")
				non_prof = positions.select{|e| !e.downcase.include? 'professor'}.join("\n")
#  positions
overview = doc.css('div[@id="overview-noRangeClass-List"]').text.strip
research = doc.css('div[@id="researchOverview-noRangeClass-List"]').text.strip
  position1 = positions.uniq[0]
  position2 = positions.uniq[1]
  position3 = positions.uniq[2]
  position4 = positions.uniq[3]
  position5 = positions.uniq[4]
education = doc.at('div.panel-heading:contains("Education And Training")').next_element.css('li').map{|e| e.text.strip.gsub(/\s+/, " ")}.join("\n") rescue ''
csv <<  ['https://www.uab.edu/medicine/pulmonary/faculty', detail_url.to_s,full_name, f_name, l_name, suffix, positions.join("\n"), position_prof,non_prof, area_of_interest.to_s,email_1.to_s,email_2.to_s,email_3.to_s, overview, research, '', education, '', '', '', '']

			end
		@i=@i+20
	end


csv.close
require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'json'

names = ["Darryl C. Abrams, M.D.", "Cara L. Agerstrand, M.D.", "Michaela Restivo Anderson, M.D., M.S.", "Selim M. Arcasoy, M.D., M.P.H.", "Amy D. Atkeson, M.D.", "Meghan Aversa, M.D.", "Jan Bakker, MD, PhD, FCCP", "Matthew R. Baldwin M.D., M.S.", "R. Graham Barr, MD, PhD", "Jeremy R. Beitler, M.D., MPH", "Luke Benvenuto, MD", "Jahar Bhattacharya, M.D., D.Phil.", "Ralph Binder, M.D.", "Keith Brenner, M.D.", "Daniel Brodie, M.D.", "William A. Bulman, M.D.", "Kristin M. Burkart,  M.D., M.Sc.", "Joseph Burzynski, M.D", "Manuel Cabrera, M.D.", "Wellington V. Cardoso, M.D., PhD", "Stephen Canfield, M.D. Ph.D.", "Subani Chandra, M.D.", "David Chong, M.D.", "Jennifer Cunningham, M.D.", "Anita Darmanian, M.D.", "Angela DiMango, M.D.", "Emily DiMango M.D.", "Sean Fedyna, M.D.", "Christine Kim Garcia, MD, PhD", "Sanja Jelic, M.D.", "Claire Keating, M.D.", "David Lederer, M.D., M.S.", "Irene Louh, M.D. Ph.D", "Purnema Madahar, M.D.", "Roger Maxfield, M.D.", "Carlton McGregor, M.D.", "Max O'Donnell, MD, MPH", "Madhavi Parekh, MD", "Kenneth Prager, M.D.", "Hilary Robbins, M.D", "John Schicchi, M.D.", "Larry Schulman,  M.D.", "Lori Shah, M.D.", "Briana Short, M.D.", "Hans-Willem Snoeck, M.D. Ph.D", "Byron Thomashow, M.D.", "Romina M. Wahab, M.D.", "Chun Yip, M.D.", "Natalie Yip, M.D.", "David Zhang, M.D."]
CSV.open("columbia_mail_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
names.each do |each_data|
	puts each_data
	# url = "https://search.sites.columbia.edu/people/#{each_data.split(',').first.split.first}"
	url = "https://search.sites.columbia.edu/directory-query.php?term=#{each_data.split(',').first.split.first}"
	doc = JSON.parse(RestClient.get(url).body)
	# byebug
	listings = doc
	listings.each do |each_list|
		name = each_list['cn']
		if((name.include?"#{each_data.split(',').first.split.first}") && (name.include?"#{each_data.split(',').first.split.last}"))
			email = each_list['mail']
			csv << [each_data, name, email]
		end
	end
end
end
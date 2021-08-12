require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'

names = ["Ravi S. Aysola, MD", "Joanne M. Bando, MD", "Igor Barjaktarevic, MD, PhD", "", "John A. Belperio, MD", "", "Gregory B. Bierer, MD", "Russell G. Buhr, MD, PhD", "", "Melisa R. Chang, MD", "Steven Y. Chang, MD, PhD", "Colleen L. Channick, MD", "Richard N. Channick, MD", "Chidinma Chima-Melton, MD", "Augustine Chung, MD", "Stella Cohen, MD", "", "Roman M. Culjat, MD", "Sharon J. De Cruz, MD", "Ariss DerHovanessian, MD", "Tamas Dolinay, MD", "Steven M. Dubinett, M.D.", "Patricia H. Eshaghian, MD", "Oscar A. Estrada, MD", "", "Susie X. Fong, MD", "Gerard W. Frank, MD", "Tomas Ganz, M.D., Ph.D.", "Brandon S. Grimes, MD, MS", "Tao He, MD, PhD", "Jason Hong, MD, MPH", "Lillian Y. Hsu, MD", "Scott B. Hu, MD", "Dale Jun, MD", "Nader Kamangar, M.D.", "Sam A. Kashani, MD", "Airie Kim, MD, PhD", "Eric C. Kleerup, MD", "Elinor Lee, MD, PhD", "", "Cole D. Liberator, MD", "Joseph P. Lynch III, MD", "Abigail E. Maller, MD", "Kathryn H. Melamed, MD", "Maryum H. Merchant, MD", "Elizabeta Nemeth, Ph.D.", "Thanh H. Neville, MD", "Catherine L. Oberg, MD", "Scott S. Oh, DO", "Alfonso J. Padilla, MD", "Nida Qadir, MD", "", "", "Michael D. Roth, MD", "", "Rajan Saggar, MD", "Ramin Salehi-rad, MD, PhD", "David M. Sayah, MD, PhD", "Sheeja T. Schuster, MD, MPH", "Corinne V. Sheth, MD", "Yusaku M. Shino, MD", "Malcolm I. Smith, MD", "", "Irawan Susanto, MD", "Donald Tashkin, M.D.", "Tisha S. Wang, MD", "Stephen S. Weigt, MD", "Yu-Ching E. Wen, MD", "May Lin Wilgus, MD", "Brian K. Wong, MD", "", "Michelle R. Zeidler, MD", "Lorraine Anderson, MD", "Chongwei Cui, MD, PhD", "Rita Kachru, MD", "Kellie J. Lim, MD", "Connie Lin, MD", "Andrew Q. Pham, MD", "Ami  Philipp, MD", "Samantha R. Swain, MD", "Monica S. Tsai, MD", "Eric Yen Yen, MD, MS", "", "Kostyantyn Krysan", "", "Jennifer McCaney, PhD", "Michael Palazzolo, M.D., Ph.D.", ""]

Selenium::WebDriver::Firefox::Service.driver_path = "C:/GeckoDriver/geckodriver.exe"
browser = Watir::Browser.new:firefox
browser.window.maximize

url = "http://directory.ucla.edu/search.php"
browser.goto(url)
CSV.open("uclahealth_email_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	names.each do |each_data|
		if each_data.to_s != ''
			browser.input(name: 'q').to_subtype.clear
			browser.input(name: 'q').send_keys"#{each_data.split(',').first.split.last}"
			browser.input(type: 'submit').click
			sleep 2
			name = browser.table(class: 'results-normal').tbody.trs[1].tds[0].text rescue ''
			email = browser.table(class: 'results-normal').tbody.trs[1].tds[1].img.alt.split(':').last rescue ''

			csv << [each_data, name, email]
		end
	end
end
# byebug
puts url
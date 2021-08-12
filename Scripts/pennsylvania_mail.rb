require 'nokogiri'
require 'rest-client'
require 'byebug'
require 'csv'
require 'watir-webdriver'
require 'watir'
require "down"
require "open-uri"

Selenium::WebDriver::Firefox::Service.driver_path = "C:/GeckoDriver/geckodriver.exe"
browser = Watir::Browser.new :firefox
browser.window.maximize

names = ["Benjamin Abella, MD, MPhil", "Jason Ackrivo, MD, MSCE", "Vivek Ahya, MD, MBA", "Steven Albelda, MD", "Nadine Al-Naamani, MD, MS", "Michaela Restivo Anderson, MD", "Brian Anderson, MD, MSCE", "George Anesi, MD, MSCE, MBE", "Audreesh Banerjee, MD", "Cameron Murray Baston, MD MSCE", "Michael Beers, MD", "Lisa Bellini, MD", "Jacob S Brenner, MD, PHD", "Joshua Brotman, MD", "Lauren Catalano, MD, MSc", "Jason Christie, MD, MS", "Melpo Christofidou-Solomidou, PhD", "Caitlin Clancy, MD", "Emily Clausen, MD", "Ronald Gary Collman, MD", "Katherine Courtright, MD", "Andrew Courtwright, MD, PHD", "Maria Crespo, MD", "Audrey Daggan, MD", "Joel Deitz, MD", "Horace DeLisser, MD", "Joshua Diamond, MD, MSCE", "David DiBardino, MD", "Jessica Dine, MD, MHSP", "Daniel Dorgan, MD", "Olajumoke Fadugba, MD", "Scott Feldman, MD, PhD", "Laura Theresa Ferguson, MD", "Judd David Flesch, MD", "Jason Fritz, MD", "Barry Fuchs, MD", "Matthew Germinaro, MD", "Michael Grippi, MD", "Andrew Haas, MD, PhD", "Denis Hadjiliadis, MD", "Scott Halpern, MD, PhD", "John Hansen-Flaschen, MD", "Joanna Hart, MD", "Janae Heath, MD, MSCE", "Gina Hong, MD", "Christoph Hutchinson, MD", "Cheilonda Johnson, MD, MHS", "Tiffanie Jones, MD", "Stacey Kassutto, MD", "Jeremy Katzen, MD", "Steven Kawut, MD", "Joshua Berkman Kayser, MD, MPH, MBE, FCCM", "Meeta Prasad Kerlin, MD, MSCE", "Paul Kinniry, MD", "Rachel Kohn, MD, MSCE", "Robert Kotloff, MD", "Maryl Kreider, MD, MSCE", "Vera Krymskaya, PhD, MBA, FCPP", "Anthony Lanfranco, MD", "Aili Lazaar, MD", "James Lee, MD", "Frank Leone, MD, MS", "Sarah Lyon, MD, MSCE", "Kevin Ma, MD", "Tamara Mahr, MD", "Scott Manaker, MD, PhD", "Nilam S Mangalmurti, MD", "Nuala Meyer, MD, MS", "Mark Mikkelsen, MD, MSCE, FCCM", "Edmund Moon, MD", "Harold Palevsky, MD", "Andrew Paris, MD", "Priya Patel, MD", "Namrata Patel, MD", "Mary Porteous, MD, MSCE", "Steven Pugliese, MD", "John Reilly, MD, MSCE", "Michael Rey, MD", "Milton Rossman, MD", "Juan Salgado, MD", "William Schweickert, MD", "Katharine Secunda, MD", "Michael Shashaty, MD, MSCE", "Michael Sims, MD, MSCE", "Kerri Akaya Smith, MD", "Shweta Sood, MD, MS", "Darren Taichman, MD", "Patricia Takach, MD, FAAAAI", "Jeffrey Thompson, MD", "Gregory Tino, MD", "Anil Vachani, MD", "Arshad A Wani, MD", "Steven Weinberger, MD", "Gary Weissman, MD"]

CSV.open("Pennsylvania_mail.csv", "w", {:col_sep => "~"}) do |csv|
	names.each do |each_name|
		begin
			browser.goto("https://www.med.upenn.edu/psom/results.html?query=#{each_name.split(',').first.gsub(' ', '+')}&resultsPerPage=8&resultsPageNum=0&search=%2F%2Fwww.med.upenn.edu%2Fapps%2Ffaculty%2Findex.php%2Fg275&searchUrls=%2F%2Fwww.med.upenn.edu%2Fapps%2Ffaculty%2Findex.php%2Fg275")
			sleep 2
			doc = Nokogiri::HTML(browser.html)
			details_url = doc.css('div.result_item_text')[0].css('a').attr('href').value
			details_doc = Nokogiri::HTML(RestClient.get(details_url).body)
			name_d = details_doc.css('h2.fac_name').text rescue ""
			email = details_doc.css('div.fac_email').css('a').attr('href').value.split(':').last rescue ""
			csv << [each_name, name_d, email]
		rescue Exception => e
			puts "exception in #{each_name}\n #{e.message}"
			puts e.backtrace
		end
		
	end
end
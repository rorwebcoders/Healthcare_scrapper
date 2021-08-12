require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'
require 'json'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


page_no = 0

CSV.open("Output/DUKE.csv", "w", {:col_sep => ","}) do |csv|
	csv << ["Detail Url", "Name", "First Name", "Last Name", "Suffix", "Title/Positions/Academic Appointments", "Position Professor", "Position Non Professor", "Interest/Subspecialty", "email1", "email2", "email3", "overview", "research", "education/training/boards", "Additional  Url", "Clinical Focus", "Awards/Pubs", "Other positions"]
	
	num = 0
	loop do 
		data = `curl 'https://medicine.duke.edu/views/ajax' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Origin: https://medicine.duke.edu' -H 'Connection: keep-alive' -H 'Referer: https://medicine.duke.edu/divisions/pulmonary-allergy-and-critical-care-medicine/faculty' -H 'Cookie: has_js=1; _ga=GA1.2.1948509910.1628410825; _gid=GA1.2.578228563.1628410825; _gat=1; _ga=GA1.3.1948509910.1628410825; _gid=GA1.3.578228563.1628410825; _dc_gtm_UA-16777919-42=1' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw 'view_name=profiles&view_display_id=block_2&view_args=2160&view_path=node%2F2160&view_base_path=faculty&view_dom_id=e9945ee1c6069dbb9ba3d0a23306f1cc&pager_element=0&page=#{page_no}&ajax_html_ids%5B%5D=menu-toggle&ajax_html_ids%5B%5D=dukealert&ajax_html_ids%5B%5D=block-logo-block-logo&ajax_html_ids%5B%5D=Layer_1&ajax_html_ids%5B%5D=block-search-form&ajax_html_ids%5B%5D=search-block-form&ajax_html_ids%5B%5D=edit-search-block-form--2&ajax_html_ids%5B%5D=edit-actions&ajax_html_ids%5B%5D=edit-submit&ajax_html_ids%5B%5D=block-menu-block-7&ajax_html_ids%5B%5D=block-menu-block-1&ajax_html_ids%5B%5D=main-content&ajax_html_ids%5B%5D=block-views-profiles-block-2&ajax_html_ids%5B%5D=views-exposed-form-profiles-block-2&ajax_html_ids%5B%5D=edit-title-wrapper&ajax_html_ids%5B%5D=edit-title&ajax_html_ids%5B%5D=edit-submit-profiles&ajax_html_ids%5B%5D=block-menu-block-13&ajax_html_ids%5B%5D=block-views-articles-block-2&ajax_html_ids%5B%5D=block-multiblock-3&ajax_html_ids%5B%5D=Layer_1&ajax_html_ids%5B%5D=block-menu-block-5&ajax_html_ids%5B%5D=block-block-1&ajax_html_ids%5B%5D=block-menu-block-4&ajax_html_ids%5B%5D=block-block-2&ajax_page_state%5Btheme%5D=duke_dom&ajax_page_state%5Btheme_token%5D=ur14Doe7yKk6qZ-LNGTsIXVGwFSb_r8XPEGRIUkIZLM&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Fsystem%2Fsystem.base.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Fsystem%2Fsystem.menus.theme.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Fsystem%2Fsystem.messages.theme.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Fsystem%2Fsystem.theme.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fdate%2Fdate_api%2Fdate.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fdate%2Fdate_popup%2Fthemes%2Fdatepicker.1.7.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Faggregator%2Faggregator.theme.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fmodules%2Fcustom%2Fdom_search%2Fdom_search.css%5D=1&ajax_page_state%5Bcss%5D%5Bmodules%2Fnode%2Fnode.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Ffield%2Ffield.theme.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fvideo_filter%2Fvideo_filter.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Fsearch%2Fsearch.theme.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fviews%2Fcss%2Fviews.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Fuser%2Fuser.base.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fcss%2Fmodules%2Fuser%2Fuser.theme.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fckeditor%2Fcss%2Fckeditor.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fmedia%2Fmodules%2Fmedia_wysiwyg%2Fcss%2Fmedia_wysiwyg.base.css%5D=1&ajax_page_state%5Bcss%5D%5Bmisc%2Fui%2Fjquery.ui.core.css%5D=1&ajax_page_state%5Bcss%5D%5Bmisc%2Fui%2Fjquery.ui.theme.css%5D=1&ajax_page_state%5Bcss%5D%5Bmisc%2Fui%2Fjquery.ui.accordion.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fctools%2Fcss%2Fctools.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fshib_auth%2Fshib_auth.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Faddtoany%2Faddtoany.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fduke_dom%2Fcss%2Fduke_dom.normalize.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fduke_dom%2Fcss%2Fduke_dom.hacks.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fduke_dom%2Fcss%2Fduke_dom.styles.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fduke_dom%2Fcss%2Fduke_dom.no-query.css%5D=1&ajax_page_state%5Bcss%5D%5B%2F%2Falertbar.oit.duke.edu%2Fsites%2Fall%2Fthemes%2Fblackwell%2Fcss%2Falert.css%5D=1&ajax_page_state%5Bcss%5D%5Bsites%2Fmedicine.duke.edu%2Fmodules%2Fcustom%2Fsom_alerts%2Fcss%2Falert_fix.css%5D=1&ajax_page_state%5Bjs%5D%5B0%5D=1&ajax_page_state%5Bjs%5D%5B1%5D=1&ajax_page_state%5Bjs%5D%5B2%5D=1&ajax_page_state%5Bjs%5D%5B3%5D=1&ajax_page_state%5Bjs%5D%5B4%5D=1&ajax_page_state%5Bjs%5D%5Bpublic%3A%2F%2Fgoogle_tag%2Fgoogle_tag.script.js%5D=1&ajax_page_state%5Bjs%5D%5B%2F%2Fajax.googleapis.com%2Fajax%2Flibs%2Fjquery%2F3.1.1%2Fjquery.min.js%5D=1&ajax_page_state%5Bjs%5D%5B%2F%2Fcode.jquery.com%2Fjquery-migrate-3.0.0.min.js%5D=1&ajax_page_state%5Bjs%5D%5Bmisc%2Fjquery-extend-3.4.0.js%5D=1&ajax_page_state%5Bjs%5D%5Bmisc%2Fjquery-html-prefilter-3.5.0-backport.js%5D=1&ajax_page_state%5Bjs%5D%5Bmisc%2Fjquery.once.js%5D=1&ajax_page_state%5Bjs%5D%5Bmisc%2Fdrupal.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fomega%2Fomega%2Fjs%2Fno-js.js%5D=1&ajax_page_state%5Bjs%5D%5B%2F%2Fajax.googleapis.com%2Fajax%2Flibs%2Fjqueryui%2F1.10.2%2Fjquery-ui.min.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fjquery_update%2Freplace%2Fui%2Fexternal%2Fjquery.cookie.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fjquery_update%2Freplace%2Fjquery.form%2F4%2Fjquery.form.min.js%5D=1&ajax_page_state%5Bjs%5D%5Bmisc%2Fform.js%5D=1&ajax_page_state%5Bjs%5D%5Bmisc%2Fajax.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fjquery_update%2Fjs%2Fjquery_update.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fmedicine.duke.edu%2Fmodules%2Fcustom%2Fdom_hr_feed%2Fjs%2Fdom_hr_feed.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fctools%2Fjs%2Fauto-submit.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fviews%2Fjs%2Fbase.js%5D=1&ajax_page_state%5Bjs%5D%5Bmisc%2Fprogress.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fviews_load_more%2Fviews_load_more.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fviews%2Fjs%2Fajax_view.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fall%2Fmodules%2Fcontrib%2Fgoogle_analytics%2Fgoogleanalytics.js%5D=1&ajax_page_state%5Bjs%5D%5Bmisc%2Fcollapse.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fduke_dom%2Fjs%2Fimagesloaded-3.1.8.min.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fduke_dom%2Fjs%2Fmasonry-3.1.5.min.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fduke_dom%2Fjs%2Fjquery.flexverticalcenter.js%5D=1&ajax_page_state%5Bjs%5D%5Bsites%2Fmedicine.duke.edu%2Fthemes%2Fduke_dom%2Fjs%2Fduke_dom.behaviors.js%5D=1&ajax_page_state%5Bjquery_version%5D=3.1'`

		json_data = JSON.parse(data)
		html = json_data.find{|x| x["command"]=="insert"}["data"]
		parsed_data = Nokogiri::HTML(html)
		
		parsed_data.css("article.node--profile.node--faculty").each_with_index do |faculty, index|
			name = faculty.css("h2.node__title").text
			num = num + 1
			puts "#{num}) #{name}"
			splitted_names = name.split(", ")[0].split(" ")
			first_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[0].join(" ")
			last_name = splitted_names.each_slice((splitted_names.length/2.to_f).ceil).to_a[1].join(" ")
			suffix = name.split(", ")[1..-1].join(", ")
			# department = faculty.css("div.field--name-field-division-ref div.field-item").map{|x| x.text}
			detail_url = "https://medicine.duke.edu" + faculty.css("h2.node__title a").attr("href").text
			details_page = Nokogiri::HTML(open(detail_url))

			splitted_positions = details_page.css("div.field--name-field-positions div.field-item").map{|x| x.text}
			position = splitted_positions.join("\n")
			professor_position = splitted_positions.select{|x| x.match(/professor/i)}.join("\n")
			non_professor_position = splitted_positions.select{|x| !x.match(/professor/i)}.join("\n")
			
			email = details_page.css("div.field--name-field-email .field-item").map{|x| x.text}.join("\n")
			education = details_page.css("div.field--name-field-education .field-item li").map{|x| x.text}.join("\n")
			overview = details_page.css(".field--name-body.field--type-text-with-summary p").map{|x| x.text}.join("\n")
			
			csv << [detail_url, name, first_name, last_name, suffix, position, professor_position, non_professor_position, "", email, "", "", overview, "", education, "", "", "", ""]
		end	

		break if parsed_data.css("article.node--profile.node--faculty").empty?
		page_no = page_no + 1
	end
end




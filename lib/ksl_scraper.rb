# lib/ksl_scraper.rb

# need an array of hashes with
#	name:
#	link:
#	org:
#	viewed: (default to false)
#	deleted: (default to false)

require 'nokogiri'
require 'open-uri'

class KslScraper

	def initialize
		@scraped_links = [] # Links found while scraping
	end

	def do_stuff(url)
		doc = Nokogiri::HTML(open(url))
		names = [] # Job titles
		link = [] # HREFs
		orgs = [] # Org names
		posted = [] # date posted

		#Grab links and Job Names
		doc.css("h2.job-title a").each do |item|
			names << item.text
			link << "https://ksl.com" + item[:href]
			@scraped_links << "https://ksl.com" + item[:href]
		end

		#Grab Org names and Job ID Nos
		doc.css("span.company-name").each do |item|
			orgs << item.text
		end

		#Grab posted date
		doc.css("span.posted-time").each do |item|
			posted << item.text.to_date
		end

		#Test array sizes match
		if link.size == orgs.size && orgs.size == names.size
			0.upto(link.size-1) do |x|

				job = Ksl.find_by link: link[x]
				if job != nil && job.posted != posted[x]
					job.destroy
					job = nil
				end
				if job == nil
					hash = {
						name: names[x],
						link: link[x],
						org: orgs[x],
						posted: posted[x],
						viewed: false
					}
					Ksl.create(hash)
				end
			end # End loop
		end # End if

		url = doc.css("a.next.link")[0]
    if url != nil
			# Scrape the next page
      do_stuff "https://ksl.com" + url[:href]
    end
	end

	def remove_stuff
		Ksl.where.not(link: @scraped_links).delete_all
	end
end

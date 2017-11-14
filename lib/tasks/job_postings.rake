desc "Fetch job postings"

# This script pulls in job postings from KSL's site
# It stores new postings into our db.
# It should also delete postings that have been removed from Weber's site

task :fetch_jobs => :environment do

	require 'ksl_scraper'

	puts "Scraping KSL jobs..."
	scrapings = KslScraper.new
	scrapings.do_stuff "https://www.ksl.com/jobs/search/miles/0/keywords/software%20engineer/page/1"
	scrapings.do_stuff "https://www.ksl.com/jobs/search/miles/0/keywords/software%20developer/page/1"
	scrapings.remove_stuff
	puts "Done."

end

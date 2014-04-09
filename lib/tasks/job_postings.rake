desc "Fetch job postings"

# This script pulls in job postings from Weber's career services site
# It stores new postings into our db and marks old postings as 'viewed'

# It should also delete postings that have been removed from Weber's site

task :fetch_jobs => :environment do 

#	require 'rubygems'
	require 'nokogiri'
	require 'open-uri'

	url = "http://saweb.weber.edu/saxtra/careerservicesfeed/FullListing.aspx"

	doc = Nokogiri::HTML(open(url))

	#puts doc.at_css("title").text

	names = [] # Job titles
	link = [] # HREFs
	table_stuff = [] # Even indecies: org name, Odd: job id no
	orgs = []
	ids = []

	doc.css("a").each do |item|
		names << item.text
		link << item[:href]
	end	

	doc.css("td").each do |item|
		table_stuff << item.text
	end

	table_stuff = table_stuff - ["Job #:", "Organization Name:"]

	orgs = table_stuff.select.each_with_index { |val, i| i.even? }
	ids = table_stuff.select.each_with_index { |val, i| i.odd? }

	#Test sizes match
	if ids.size == orgs.size && orgs.size == names.size
		0.upto(ids.size-1) do |x|
			job = Job.find_by_job_id(ids[x])
			
			if job
				job.update_attributes({
					viewed: true
				})
			else
				job = Job.new({ 	name: names[x],
					link: link[x],
					org: orgs[x],
					viewed: false,
					job_id: ids[x]
				})
				job.save
			end
			puts names[x] + " done"
		end		
	end
end

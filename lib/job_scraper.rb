# lib/job_scraper.rb

# need an array of hashes with
#	name:
#	link:
#	org:
#	viewed: (default to false)
#	deleted: (default to false)
#	job_id:

require 'nokogiri'
require 'open-uri'

class JobScraper
	
	# This will scrape the page and put all jobs into an array
	def initialize(curr_jobs)
		@jobs = curr_jobs
		@page_jobs = [] # All jobs on page
		@new_jobs = [] # New jobs - add to db
		@viewed_jobs = [] # Jobs already in db - set viewed true
		
		url = "http://saweb.weber.edu/saxtra/careerservicesfeed/FullListing.aspx"
		doc = Nokogiri::HTML(open(url))

		names = [] # Job titles
		link = [] # HREFs
		table_stuff = [] # Even indecies: org name, Odd: job id no
		orgs = [] # Org names
		ids = [] # Job ID Nos

		#Grab links and Job Names
		doc.css("a").each do |item|
			names << item.text
			link << item[:href]
		end	

		#Grab Org names and Job ID Nos
		doc.css("td").each do |item|
			table_stuff << item.text
		end

		# Housekeeping
		table_stuff = table_stuff - ["Job #:", "Organization Name:"]
		orgs = table_stuff.select.each_with_index { |val, i| i.even? }
		ids = table_stuff.select.each_with_index { |val, i| i.odd? }

		#Test array sizes match
		if ids.size == orgs.size && orgs.size == names.size
			0.upto(ids.size-1) do |x|
							
				hash = {
						name: names[x],
						link: link[x],
						org: orgs[x],
						job_id: ids[x]
						}

				@page_jobs.push(hash)
				
			end # End loop		
		end # End if

		puts "************** Page Jobs: ***************"
		puts @page_jobs.size > 0 ? @page_jobs.size : "None."
		puts "************** /Page Jobs ***************"

		puts "************** Db Jobs: ***************"
		puts @jobs.size > 0 ? @jobs.size : "None."
		puts "************** /Db Jobs ***************"
	end

	# This will return an array of jobs to add to db	
	def new_jobs
		db_job_ids = []
		page_job_ids = []
		new_job_ids = []

		@page_jobs.each { |x| page_job_ids.push(x[:job_id]) }
		@jobs.each { |x| db_job_ids.push(x[:job_id]) }
		new_job_ids = page_job_ids.reject do |p| 
			db_job_ids.detect do |d| 
				d.to_s == p.to_s 
			end
		end
		
		puts "************** New Job Ids: ***************"
		puts new_job_ids.size > 0 ? new_job_ids.size : "None."
		puts "************** /New Job Ids ***************"
		
		@page_jobs.each do |x|
			if new_job_ids.detect { |n| x[:job_id] == n }
				@new_jobs.push(x)
			end
		end

		puts "************** New Jobs: ***************"
		puts @new_jobs.size > 0 ? @new_jobs.size : "None."
		puts "************** /New Jobs ***************"

		return @new_jobs
	end

	# This will return an array of job_ids that should be set to 'viewed'
	def viewed
		viewed_job_ids = []

		@jobs.each do |j|
			unless j.viewed
				viewed_job_ids.push(j[:job_id])
			end
		end

		puts "************** Viewed Job Ids: ***************"
		puts viewed_job_ids.size > 0 ? viewed_job_ids.size : "None."
		puts "************** /Viewed Job Ids ***************"

		return viewed_job_ids
	end

	# This will return an array of job_ids that are no longer on the page
	def removed
		db_job_ids = []
		page_job_ids = []
		removed_job_ids = []

		@page_jobs.each { |x| page_job_ids.push(x[:job_id]) }
		@jobs.each { |x| db_job_ids.push(x[:job_id]) }
		removed_job_ids = db_job_ids.reject do |d| 
			page_job_ids.detect do |p| 
				d.to_s == p.to_s 
			end
		end

		puts "************** Removed Job Ids: ***************"
		puts removed_job_ids.size > 0 ? removed_job_ids.size : "None."
		puts "************** /Removed Job Ids ***************"
		
		return removed_job_ids
	end

end

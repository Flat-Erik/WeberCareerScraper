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

class KslScraper

	# This will scrape the page and put all jobs into an array
	def initialize(curr_jobs)
		@jobs = curr_jobs
		@page_jobs = [] # All jobs on page
		@new_jobs = [] # New jobs - add to db
		@viewed_jobs = [] # Jobs already in db - set viewed true

		puts "************** Db Jobs: ***************"
		puts @jobs.size > 0 ? @jobs.size : "None."
		puts "************** /Db Jobs ***************"
	end

  def scrape_url(url)
    doc = Nokogiri::HTML(open(url))

		names = [] # Job titles
		link = [] # HREFs
		orgs = [] # Org names

		#Grab links and Job Names
		doc.css("h2.job-title a").each do |item|
			names << item.text
			link << "https://ksl.com" + item[:href]
		end

		#Grab Org names and Job ID Nos
		doc.css("span.company-name").each do |item|
			orgs << item.text
		end

		#Test array sizes match
		if link.size == orgs.size && orgs.size == names.size
			0.upto(link.size-1) do |x|

				# Don't keep multiple links
				if @page_jobs.detect {|p| p[:link] == link[x]} == nil
					hash = {
						name: names[x],
						link: link[x],
						org: orgs[x]
					}

					@page_jobs.push(hash)
				end

			end # End loop
		end # End if

    url = doc.css("a.next.link")[0]
    if url != nil
      scrape_url "https://ksl.com" + url[:href]
    end

		puts "************** Page Jobs: ***************"
		puts @page_jobs.size > 0 ? @page_jobs.size : "None."
		puts "************** /Page Jobs ***************"
  end

	# This will return an array of jobs to add to db
	def new_jobs
		db_job_ids = []
		page_job_ids = []
		new_job_ids = []

		@page_jobs.each { |x| page_job_ids.push(x[:link]) }
		@jobs.each { |x| db_job_ids.push(x[:link]) }
		new_job_ids = page_job_ids.reject do |p|
			db_job_ids.detect do |d|
				d.to_s == p.to_s
			end
		end

		puts "************** New Job Ids: ***************"
		puts new_job_ids.size > 0 ? new_job_ids.size : "None."
		puts "************** /New Job Ids ***************"

		@page_jobs.each do |x|
			if new_job_ids.detect { |n| x[:link] == n }
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
				viewed_job_ids.push(j[:link])
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

		@page_jobs.each { |x| page_job_ids.push(x[:link]) }
		@jobs.each { |x| db_job_ids.push(x[:link]) }
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

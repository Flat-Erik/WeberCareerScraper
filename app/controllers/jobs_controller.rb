# Make selecting multiple jobs easier now
class JobsController < ApplicationController

	require 'nokogiri'
	require 'open-uri'

	def index
		if request.post?
			unless params[:job_ids] == nil
			 Job.update_all({deleted: true}, :id => params[:job_ids].keys)
			end
		end

		@jobs = Job.all.order(job_id: :desc)	
		@jobs = @jobs.select { |j| j.deleted != true }
	end

	def scrape
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
				job = Job.find_by_job_id(ids[x])
			
				if job # If job in db, make sure viewed is set true
					unless job.viewed
						job.update_attributes({
							viewed: true
						})
					end
				else # Else create a new job
					job = Job.new({ 	name: names[x],
						link: link[x],
						org: orgs[x],
						viewed: false,
						job_id: ids[x]
					})
					job.save
				end
				# What will happen here?
				puts names[x] + " done"
			end		
		end

		redirect_to action: 'index'
	end


end

require 'job_scraper'

class JobsController < ApplicationController

	def index
		if request.post?
			unless params[:job_ids] == nil
				Job.where(id: params[:job_ids].keys).update_all(deleted: true)
			end
		end
		@jobs = Job.all.order(:viewed, job_id: :desc)
		@total = @jobs.count
		@jobs = @jobs.select { |j| j.deleted != true }
	end

	def scrape

		scrapings = JobScraper.new(Job.all)

		viewed_jobs = scrapings.viewed
		if viewed_jobs.size > 0
			Job.where(job_id: viewed_jobs).update_all(viewed: true)
		end

		new_jobs = scrapings.new_jobs
		if new_jobs.size > 0
			Job.create(new_jobs)
		end

		removed_jobs = scrapings.removed
		if removed_jobs.size > 0
			Job.where(job_id: removed_jobs).delete_all
		end

		redirect_to action: 'index'
	end


end

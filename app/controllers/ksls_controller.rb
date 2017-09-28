require 'ksl_scraper'

class KslsController < ApplicationController
  def index
    if request.post?
      unless params[:links] == nil
			 Ksl.update_all({deleted: true}, :link => params[:links].keys)
			end
    end
    @jobs = Ksl.all(:order => 'viewed asc, updated_at desc')
		@total = @jobs.count
		@jobs = @jobs.select { |j| j.deleted != true }
  end

  def scrape
  	scrapings = KslScraper.new(Ksl.all)

  	viewed_jobs = scrapings.viewed
  	if viewed_jobs.size > 0
  		Ksl.where(link: viewed_jobs).update_all(viewed: true)
  	end

  	# new_jobs = scrapings.new_jobs
  	# if new_jobs.size > 0
  	# 	Ksl.create(new_jobs)
  	# end
    #
  	# removed_jobs = scrapings.removed
  	# if removed_jobs.size > 0
  	# 	Ksl.where(link: removed_jobs).delete_all
  	# end
    #
  	# redirect_to action: 'index'
  end
end

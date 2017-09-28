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
    @scrapings = KslScraper.new(Ksl.all)

    @scrapings.scrape_url "https://www.ksl.com/jobs/search/miles/0/keywords/software%20engineer/page/1"
    scrape_page

    @scrapings.scrape_url "https://www.ksl.com/jobs/search/miles/0/keywords/software%20developer/page/1"
    scrape_page

    removed_jobs = @scrapings.removed
  	if removed_jobs.size > 0
  		Ksl.where(link: removed_jobs).delete_all
  	end

  	redirect_to action: 'index'
  end

  private
  def scrape_page
  	viewed_jobs = @scrapings.viewed
  	if viewed_jobs.size > 0
  		Ksl.where(link: viewed_jobs).update_all(viewed: true)
  	end

  	new_jobs = @scrapings.new_jobs
  	if new_jobs.size > 0
  		Ksl.create(new_jobs)
  	end
  end
end

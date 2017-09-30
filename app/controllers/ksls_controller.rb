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
    scrapings = KslScraper.new
    scrapings.do_stuff "https://www.ksl.com/jobs/search/miles/0/keywords/software%20engineer/page/1"
    scrapings.do_stuff "https://www.ksl.com/jobs/search/miles/0/keywords/software%20developer/page/1"
    scrapings.remove_stuff

  	redirect_to action: 'index'
  end
end

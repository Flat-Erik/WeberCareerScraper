require 'ksl_scraper'

class KslsController < ApplicationController
  def index
    if request.post?
      unless params[:links] == nil
			Ksl.where(link: params[:links].keys).update_all(deleted: true)
			end
    end
    @jobs = Ksl.all.order(:viewed, posted: :desc)
		@total = @jobs.count
		@jobs = @jobs.select { |j| j.deleted != true }
    render
    Ksl.where(viewed: false).update_all viewed: true # Good place to change this
  end

  def scrape
    scrapings = KslScraper.new
    scrapings.do_stuff "https://www.ksl.com/jobs/search/miles/0/keywords/software%20engineer/page/1"
    scrapings.do_stuff "https://www.ksl.com/jobs/search/miles/0/keywords/software%20developer/page/1"
    scrapings.remove_stuff

  	redirect_to action: 'index'
  end
end

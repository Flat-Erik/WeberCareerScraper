Scraper::Application.routes.draw do
  get "ksls" => "ksls#index"
  post 'ksls' => 'ksls#index'
  get "ksls/scrape"

  root 'ksls#index'

end

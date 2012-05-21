require 'sinatra'
require 'mechanize'
require 'json'

require "lib/scrape.rb"

get '/' do
  erb :index
end

get '/data' do
  scraper = Scraper.new
  scraper.connect Mechanize.new
  scraper.find(params[:q])
  scraper.find_citations if params[:citations]
  scraper.over((params[:as_ylo].to_i)..(params[:as_yhi].to_i))
  scraper.results.to_json
end

run Sinatra::Application

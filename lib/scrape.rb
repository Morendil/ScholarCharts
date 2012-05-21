require 'rubygems'
require 'mechanize'

class Scraper

  def connect mech
    @mech = mech
  end

  def find query
    @q = query
  end

  def cols
    {"cols"=>[{"id"=>"","label"=>"Year","type"=>"string"},{"id"=>"","label"=>"Cite count"}]}
  end

  def rows
    @period.map {|year| row_for year}
  end

  def row_for year
    {"c"=>[{"v"=>year.to_s},{"v"=>(hits_for year)}]}
  end

  def hits_for year
    url = "http://scholar.google.com/scholar"
    params = {:as_ylo=>year,:as_yhi=>year}
    params[:q] = @q unless cluster
    params[:cites] = cluster if cluster
    page = @mech.get(url,params)
    msg = page.search("//*[@id='gs_ab_md']/text()[1]").to_s
    msg.scan(/[0-9]+/)[0].to_i
  end

  def find_citations
    url = "http://scholar.google.com/scholar"
    page = @mech.get(url,:q=>@q)
    msg = page.search("//*[@id='gs_ccl']/div[1]/div[4]/a[1]/@href").text
    @cluster = CGI::parse(URI(msg).query)["cites"][0]
  end

  def cluster
    @cluster
  end

  def over range
    @period = range
  end

  def results
    cols.merge("rows"=>rows)
  end

end
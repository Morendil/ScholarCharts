require 'test/unit'
require 'rr'

require 'rubygems'
require 'json'
require 'mechanize'

require "lib/scrape.rb"


class TestScrape < Test::Unit::TestCase
  include RR::Adapters::TestUnit

  def test_scraper_cols
    s = Scraper.new
    assert_equal JSON(header), s.cols
  end

  def test_scraper_one_row
    s = Scraper.new
    s.over 1974..1974
    mock(s). hits_for(1974) {1}
    r = s.rows
    assert_equal 1, r.length
    assert_equal( {"c"=>[{"v"=>"1974"},{"v"=>1}]}, r[0] )
  end

  def test_scraper_scrape_count
    s = Scraper.new

    # Mock interaction with Mechanize
    m = Mechanize.new
    q = "\"managing the development of large\""
    body = File.open('test/scraper_scrape_count.html', 'rb') { |file| file.read }
    params = {:q=>q,:as_ylo=>1974,:as_yhi=>1974}
    url = "http://scholar.google.com/scholar"
    mock(m).get(url,params) {Mechanize::Page.new nil,nil, body, nil, m}

    s.connect m
    s.over 1974..1974
    s.find q
    assert_equal 1, (s.hits_for 1974)
  end

  def test_scraper_cites_first
    s = Scraper.new

    # Mock interaction with Mechanize
    m = Mechanize.new
    q = "\"managing the development of large\""
    body = File.open('test/scraper_scrape_cluster.html', 'rb') { |file| file.read }
    params = {:q=>q}
    url = "http://scholar.google.com/scholar"
    mock(m).get(url,params) {Mechanize::Page.new nil,nil, body, nil, m}
    s.connect m
    s.find q
    s.find_citations
    assert_equal "15762917794343529487", s.cluster
  end

  def header
<<EOT
{
  "cols": [
        {"id":"","label":"Year","type":"string"},
        {"id":"","label":"Cite count"}
      ]
}
EOT
  end

end

require 'coinmarketcap/version'
require 'open-uri'
require 'httparty'
require 'nokogiri'

module Coinmarketcap
  def self.coins(limit = nil)
    if limit.nil?
      HTTParty.get('https://api.coinmarketcap.com/v1/ticker/')
    else
      HTTParty.get("https://api.coinmarketcap.com/v1/ticker/?limit=#{limit}")
    end
  end

  def self.coin(id, currency = 'USD')
    HTTParty.get("https://api.coinmarketcap.com/v1/ticker/#{id}/?convert=#{currency}")
  end

  # sorts in order of rank, only use argument 'rank'
  def self.coins_sort(limit = nil, key = 'rank', order = 'asc')
    if limit.nil?
      response = HTTParty.get('https://api.coinmarketcap.com/v1/ticker/')
    else
      response = HTTParty.get("https://api.coinmarketcap.com/v1/ticker/?limit=#{limit}")
    end
    if ['id', 'name', 'symbol'].include?(key)
      sorted_response = response.sort{ |a, b| a[key] <=> b[key] }
    elsif response[0].keys.include?(key)
      sorted_response = response.sort{ |a, b| a[key].to_i <=> b[key].to_i }
    else
      raise ArgumentError, "wrong argument: '#{key}'"
    end
    if order == 'asc'
      sorted_response
    elsif order == 'desc'
      sorted_response.reverse
    else
      raise ArgumentError, "wrong argument: '#{order}'"
    end
  end

  def self.global(currency = 'USD')
    HTTParty.get("https://api.coinmarketcap.com/v1/global/?convert=#{currency}")
  end

   # shows market capitalization of called crypto with default usd
  def self.coin_marketcap(id, currency = 'USD')
    HTTParty.get("https://api.coinmarketcap.com/v1/ticker/#{id}/?convert=#{currency}").first["market_cap_usd"].to_i
  end

  # shows total cryptocurrency market capitalization
  def self.total_marketcap(currency = 'USD')
    HTTParty.get("https://api.coinmarketcap.com/v1/global/?convert=#{currency}").first{"total_market_cap_usd"}.last
  end

  # shows market capitalization of called crypto divided by total market capitalization
  def self.percent_marketcap(id, currency = 'USD')
    x = self.coin_marketcap(id, currency = 'USD')
    y = self.total_marketcap(currency = 'USD')
    percent = (x / y)*100
    if percent == 0.0
      return "No data available"
    else 
      return "#{percent} %"
    end
  end

  def self.rank(id, currency = 'USD')
    HTTParty.get("https://api.coinmarketcap.com/v1/ticker/#{id}/?convert=#{currency}").first["rank"].to_i
  end

  def self.top_fifty(id, currency = 'USD')
    x = self.rank(id, currency = 'USD') 
    if x > 50
      return "Not in top 50 coins, rank is #{self.rank(id, currency = 'USD')}"
    elsif x <= 50
      return "In top 50 coins, rank is #{self.rank(id, currency = 'USD')}"
    else id == 0
      return "No data on coin rank"
    end
  end
end

  #def self.get_historical_price(id, start_date, end_date) # 20170908
    #prices = []
    #doc = Nokogiri::HTML(open("https://coinmarketcap.com/currencies/#{id}/historical-data/?start=#{start_date}&end=#{end_date}"))
    #rows = doc.css('tr')
    #if rows.count == 31
      #doc = Nokogiri::HTML(open("https://coinmarketcap.com/assets/#{id}/historical-data/?start=#{start_date}&end=#{end_date}"))
      #rows = doc.css('tr')
    #end
    #rows.shift
    #rows.each do |row|
      #begin
        #each_row = Nokogiri::HTML(row.to_s).css('td')
        #if each_row.count > 1
          #price_bundle = {}
          #price_bundle[:date] = Date.parse(each_row[0].text)
          #price_bundle[:open] = each_row[1].text.to_f
          #price_bundle[:high] = each_row[2].text.to_f
          #price_bundle[:low] = each_row[3].text.to_f
          #price_bundle[:close] = each_row[4].text.to_f
          #price_bundle[:avg] = (price_bundle[:high] + price_bundle[:low]) / 2.0
          #prices << price_bundle
        #end
      #rescue
        #next
      #end
    #end
    #prices
  #end
#end
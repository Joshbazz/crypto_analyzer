require 'bundler/setup'
require "cryptocompareapi/version"
require 'open-uri'
require "httparty"
require 'json'

module Cryptocompareapi
	include HTTParty
	base_uri "min-api.cryptocompare.com"
	def self.exchanges
		HTTParty.get('https://min-api.cryptocompare.com/data/all/exchanges')
		# have to use json to parse
	end

	def self.top_exchanges(ticker, currency = 'USD')
		x = HTTParty.get("https://min-api.cryptocompare.com/data/top/exchanges/full?fsym=#{ticker}&tsym=#{currency}&limit=5")["Response"]
		if x == "Error"
			return "No data on exchanges"
		else 
			return HTTParty.get("https://min-api.cryptocompare.com/data/top/exchanges/full?fsym=#{ticker}&tsym=#{currency}&limit=5")["Data"]["Exchanges"].map{ |x| x["MARKET"] }
		end
	end

	def self.exchange_volume(ticker, currency = 'USD')
		x = HTTParty.get("https://min-api.cryptocompare.com/data/top/exchanges?fsym=#{ticker}&tsym=#{currency}")["Data"].map{ |x| x["exchange"] }
		y = HTTParty.get("https://min-api.cryptocompare.com/data/top/exchanges?fsym=#{ticker}&tsym=#{currency}")["Data"].map{ |x| x["volume24h"] }
		z = HTTParty.get("https://min-api.cryptocompare.com/data/top/exchanges?fsym=#{ticker}&tsym=#{currency}")["Data"].map{ |x| x["volume24hTo"] }
		return x, y, z
	end

	def self.event(ticker, currency = 'USD', time)
		x = Date.parse("#{time}").to_time.to_i + 259200
		y = HTTParty.get("https://min-api.cryptocompare.com/data/histoday?fsym=#{ticker}&tsym=#{currency}&limit=6&aggregate=1&toTs=#{x}")
		z = y["Data"][0..6].map{ |x| x["low"] }
		a = y["Data"][0..6].map{ |x| x["high"] }
		b = y["Data"][0..6].map{ |x| x["time"] }
		lowhigh = [z.min, a.max]
		return b
	end

	def self.alltime_high(ticker, currency = 'USD', time)
		x = Date.parse("#{time}").to_time.to_i
		y = HTTParty.get("https://min-api.cryptocompare.com/data/histoday?fsym=#{ticker}&tsym=#{currency}&limit=90&aggregate=1&toTs=#{x}")
		a = y["Data"][0..90].map{ |x| x["high"] }
		b = y["Data"][0..90].map{ |x| x["time"] }
		alltimehigh = a.max
		return b
	end
end


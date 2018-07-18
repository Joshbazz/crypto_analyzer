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
#Currently no way (through APIs I've seen [coinmarketcap and cryptocompare]) to pull data on top exchanges: need physical list of top exchanges, compare against these outputs based on coin
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
		x = Date.parse("#{time}").to_time.to_i + 345600
		y = HTTParty.get("https://min-api.cryptocompare.com/data/histoday?fsym=#{ticker}&tsym=#{currency}&limit=6&aggregate=1&toTs=#{x}")
		z = y["Data"][0..6]
		low = z.map{ |x| x["low"] }
		high = z.map{ |x| x["high"] }
		time = z.map{ |x| x["time"] }
		lowhigh = [low.min, high.max]
		data = [low, high, time]
		return data
	end

	def self.alltime_high(ticker, currency = 'USD', time)
		x = Date.parse("#{time}").to_time.to_i
		y = HTTParty.get("https://min-api.cryptocompare.com/data/histoday?fsym=#{ticker}&tsym=#{currency}&limit=90&aggregate=1&toTs=#{x}")
		z = HTTParty.get("https://min-api.cryptocompare.com/data/price?fsym=#{ticker}&tsyms=USD")["USD"]
		a = y["Data"][0..90].map{ |x| x["high"] }
		b = y["Data"][0..90].map{ |x| x["time"] }
		alltimehigh = a.max
		percent = (a.max/z)*100
			if percent < 250
				return "within 250% range from 90 day high price. price today is #{z}, 90 day high is #{alltimehigh}"
			else 
				return "not within 250% range of 90 day high price, price today is #{z}, 90 day high is #{alltimehigh}"
			end
		#return percent
	end

	#work in progress of model 2. user looks at coinmarketcap under recently added coins, finds coin ticker, inputs ticker and current date (yyy-mm-dd)
	#listing_open: finds the opening price from last 7 days (should be equivalent to listing price b/c they are all less than or equal to 7 days old)
	#high: finds highest spot price from last 7 days
	#divides high by listing => if returns greater than 200, coin has seen 200% increase in price since listing already
	def self.new_coin(ticker, currency = 'USD', time)
		x = Date.parse("#{time}").to_time.to_i
		price_7_days = HTTParty.get("https://min-api.cryptocompare.com/data/histoday?fsym=#{ticker}&tsym=#{currency}&limit=7&aggregate=1&toTs=#{x}")
		high = price_7_days["Data"][0..7].map{ |x| x["high"] }.max
		listing_open = price_7_days["Data"].first["open"]
		return (high/listing_open)*100
	end

end


require 'open-uri'
require 'ostruct'
require 'csv'
require 'yaml'  

class Time
  def to_s
    strftime("%m %d %Y %I %M %p") 
  end                   
end

class StockData
	include Enumerable 

	SOURCE_URL = "http://finance.yahoo.com/d/quotes.csv"

	OPTIONS = {
      :symbol => "s",
      :name => "n",
      :last_trade => "l1",
      :last_trade_date => "d1",
      :last_trade_time => "t1",
      :open => "o",
      :high => "h",
      :low => "g",
      :high_52_week => "k",
      :low_52_week => "j"
	}

	def initialize(symbols, options = [:symbol,:name,:last_trade,:last_trade_date,
		                               :last_trade_time,:open,:high,:low,:high_52_week,
		                               :low_52_week])
	  @symbols = symbols
	  @options = options
	  @data = nil
	end

	def each
		data.each do |row|
			struct = OpenStruct.new(Hash[*(@options.zip(row).flatten)])
			yield struct
		end
	end

	def each_hash
		data.each do |row|
			hash = Hash[*(options.zip(row).flatten)]
			yield hash
		end
	end

	def refresh
		symbol_fragment = @symbols.join "+"
		option_fragment = @options.map{|s| OPTIONS[S] }.join ""
		url = SOURCE_URL + "?s=#{symbol_fragment}&f=#{option_fragment}"
		@data = []
		CSV.parse open(url).read do |row|
			@data << row
		end
	end

		def data
			refresh unless @data
		end
end

class StockTransaction
	attr_reader :share, :price, :last_trade_date

	def initialize(shares, price)
		@shares = shares
		@price = price
		@date = Time.now
	end

	def cost
		@price * @shares
	end

	def to_s

		((@share > 0)? "Bought":"Sold") +
		" #{shares.abs} on #{date} for #{cost.abs}, at #{price}"
	end
end


class StockHistory
	attr_reader :symbol, :name, :history

	def initialize(symbol, name)
		@symbol = symbol
		@name = name
		@history = []
	end

	def net_shares
		hisotry.inject(0){ |shares, transaction|
			shares + transaction.shares
		}
	end

	def net_balance
		history.inject(0) {|balance, transaction|
			balance + transaction.cost
		}
	end

	def started
		history.first.date unless hisotry.empty?
	end

	def buy(shares, price)
		if (shares > 0 and price > 0)
			history << StockTransaction.new(shares.abs, price)
		else
			puts "Could not buy #{shares} of #{name || symbol},
			      You only have #{net_shares} shares. "
	    end
	end

	def sell(shares, price)
		if (net_shares >= shares and shares > 0 and price > 0)
			history << StockTransaction.new(shares.abs*-1, price)
		else
			puts "Could not sell #{shares} of #{name || symbol},
			      You only have #{net_shares} shares. "
	    end
    end

	def to_s 
		lines = []
		lines << "#{name}(#{symbol}"
		hisotry.each do |t|
			line << t.to_s
		end
		line.join "\n"
	end
end

class StockPortfolio
	DEFAULT_INFO = [:symbol, :name, :last_trade]
	attr :stocks

	def initialize()
		@stocks = {}
	end

	def transaction(purchase, &block)
		data = StockData.new(purchase.key,DEFUALT_INFO)
		data.each do |stock|
			price = stock.last_trade.to_f
			if not price == 0
				history = @stocks[ stock.symbol ] ||= 
				          StockHistory.new(stock,symbol,stock.name)
				yield [history,purchase[stock.symbol],
			           stock.last_trade.to_f]
			else 
				puts "Could not find #{stock.symbol}"
			end
		end
	end

	def buy(purchase)
		transaction(purchase) {|history, shares, price|
			history.buy(shares,price)
		}
	end

	def sell(purchase)
		transaction(purchase) {|history, shares, price|
			history.sell(shares,price)
		}
	end

	def history(symbol=nil)
		if (symbol)
			puts stocks[symbol]
		else
			stocks.key.each{|s| history s unless s.nil?}
		end
	end

	def report()
		data = StockData.new(stocks.keys, DEFAULT_INFO)

		data.each do |stock|
			history = stocks[stock.symbol]
			if (history)
				gain = (history.net_shares * stock.last_trade.to_f) -
				        history.net_balance
				puts "#{stock.name}(#{stock.symbol}), " +
				"Started #{history.started}"
				puts "Gain = Shares X Price - Balance"
				puts "$#{gain} = #{history.net_shares} x" +
				"$#{stock.last_trade.to_f} - $#{history.net_blance}"
				puts ""

			end
		end
	end
end

class StockApp
	QUIT = /^exit|^quit/
	BUY = /^buy\s + ((\d +\s +\w + )(\,\s*\d+\s+\w+)*)\s*$/
	SELL = /^sell\s + ((\d +\s +\w + )(\,\s*\d+\s+\w+)*)\s*$/
	HISTORY = /^history\s*(\w+)?\s*$/
	REPORT = /^report\s*$/
	VIEW = /^view\s+((\w+)(\,\s*\w+)*)\s*$/
    HELP = /^help|^\?/

    def initialize(path = "stock_data.yaml")
    	if File.exist? path
    		puts "Loading Portfolio from #{path}"
    		@portfolio = YAML.load(open(path).read)
    		@porfolio.report
    	else
    		puts "Starting a new portfolio"
    		@portfolio = StockPortfolio.new()
    	end
    end

    def run
    	command = nil

    	while (STDOUT << ">"; command = gets.chomp)

    		case command
	    		when QUIT
	    			puts "Saving data"
	    			open(@path,"w") {|f| f<<@portfolio.to_yaml}
	    			puts "Good Bye"
	    			break

	            when REPORT
	                @portfolio.report

	            when BUY
	                purchases = parse_purchases($1)
	                @portfolio.buy purchases
	                @portfolio.report

	            when SELL
	                purchases = parse_purchases($1)
	                @portfolio.sell purchases
	                @portfolio.report

	            when VIEW
	                symbols = ($1).split
	                options = [:symbol, :name, :last_trade]
	                data = StockData.new(symbols, options)
	                data.each do |stock|
	                    puts "#{stock.name} (#{stock.symbol} " +
	                         "$#{stock.last_trade})"
	                end

	            when HISTORY
	                symbol = $1 ? ($1).upcase : nil
	                @portfolio.history(symbol)

	            when HELP
	               help()
	            else
	                puts "Enter: 'help' for help, or 'exit' to quit."
	        end
        end
    end

    def parse_purchases(str)
        purchases = {}
        str.scan(/(\d+)\s+(\w+)/){|pair| purchases[$2.upcase] = $1.to_i}
        purchases
    end

    def help
        puts <<END_OF_HELP
Commands:
[buy]: Purchase Stocks
    buy Shares Symbol[, Shares Symbol...]
    example: buy 30 GOOG, 10 MSFT

[sell]: Sell Stocks
    sell Shares Symbol[, Shares Symbol...]
    example: sell 30 GOOG, 10 MSFT

[history]: View your transaction history
    history [Symbol]
    example: history GOOG

[report]: View a report of your current stocks
    report

[view]: View the current price of a stock
    view Symbol[, Symbol...]
    example: view GOOG, MSFT

[exit]: Quit the stock application (also quit)

END_OF_HELP

    end

end

if __FILE__ ==$0
	app = if ARGV.length > 0
		StockApp.new(ARGV.pop)
	else
		StockApp.new()
	end
	app.run
end










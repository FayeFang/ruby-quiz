module ToOneHundred

	def self.input
		'123456789'
	end

	def self.operator
		[
			'+--',
			'-+-',
			'--+'
		]
	end

	def self.algorithm
		input = ToOneHundred.input
		operator = ToOneHundred.operator
		combination = []
		(0..5).each do |a|
			(a+1..6).each do |b|
				(b+1..7).each do |c|
					(c+1..8).each do |d|
						first = input[0..b-1].to_i
						second = input[b..c-1].to_i
						third = input[c..d-1].to_i
						fourth = input[d..-1].to_i
						combination << [first,second,third,fourth]
				    end
				end
			end
		end
		combination.uniq.each do|combo|
			operator.each do |sign|
				result = combo[0].send(sign[0], combo[1])
				result = result.send(sign[1], combo[2])
				result = result.send(sign[2], combo[3])
				puts "#{combo[0]} + #{combo[1]} + #{combo[2]} + #{combo[3]}  = #{result}" if result != 100
				puts ["*"*30, "#{combo[0]} + #{combo[1]} + #{combo[2]} + #{combo[3]}  = #{result}", "*"*30] if result == 100
			end
		end
		puts "#{combination.uniq.length * operator.length} possible equations been tested"
	end
end

# input = ToOneHundred.input
# operator = ToOneHundred.operator
a = ToOneHundred.algorithm
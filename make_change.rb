def make_change(amount = nil, coins = [25, 10, 5, 1])

	coins ||= [25, 10, 5, 1]

	max_occurence = amount / coins.min 

	total = 0

	while total != amount

		combination = ((0..max_occurence).to_a * (max_occurence + 1)).shuffle.sample(coins.length)

		total = 0

		coins.each_with_index do |coin, index|
			total += coin * combination[index].to_i
		end

    end

    combination.each_with_index do |occur, index|
    	puts "Coin   Number in the change"
    	puts "#{coins[index]}       #{occur}"
    end
  end
end


make_change(79,[25, 10, 5, 2])
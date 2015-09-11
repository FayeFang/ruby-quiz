def total_value(dealer)
	dealer.each_with_index.inject(0) { |s, (c, i)| 
          s+c > 21 - (dealer.size - (i + 1)) && c==11 ?  s+1 : s+c
	}
end

score_count = 0

(2..11).each do |a|
	upcard = a
	deck = ((2..11).to_a*8).tap{ |c| c.delete_at c.index(upcard) }

	score_count = [0]*27
	1000000.times{
		dealer = [upcard]
		shuffled_deck = deck.dup.shuffle
		dealer << shuffled_deck.pop while total_value(dealer) < 17
		if total_value(dealer) == 21 && (upcard == 10 || upcard == 11) && dealer.length == 2
			tot_value = 16
		else
			tot_value = total_value(dealer)
		end
		score_count[tot_value] += 1
    }
    puts "upcard is #{upcard}"
    puts %w[natural 17 18 19 20 21 bust].join('     ')
	puts (score_count[16..21] << score_count[22..-1].reduce(:+)).map{ |x| '%-4.1f%%  ' % (100.00 * x / 1000000) }.join('')
end

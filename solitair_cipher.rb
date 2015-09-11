# Cryptologist Bruce Schneier designed the hand cipher 
# "Solitaire" for Neal Stephenson's book "Cryptonomicon". 
# Created to be the first truly secure hand cipher, 
# Solitaire requires only a deck of cards for the encryption 
# and decryption of messages.

# While it's true that Solitaire is easily completed by 
# hand given ample time, using a computer is much quicker 
# and easier. Because of that, Solitaire conversion routines 
# are available in many languages, though I've not yet run across 
# one in Ruby.

# This week's quiz is to write a Ruby script that does the 
# encryption and decryption of messages using the Solitaire 
# cipher.

class Encrypter

  def initialize(keystream)
  	@keystream = "WESER FMEBQ EVXXX"
  end

  def sanitize(s)
    #uppercase and remove all the non-alphabets
  	s = s.upcase.tr("^A-Z","")
  	s = s.scan(/.{5}|.+/).join(" ")
    #add X 
  	while s.size % 6 != 0
  		s += "X"
  	end
    # delete the last character
  	s = s.chop
  end

  def letter_to_number(s)
  	letters = ("A".."Z").to_a.join
  	s = s.scan(/.{1}|.+/).join(" ")
  	s = s.gsub(/[A-Z]/) {|i| letters.index(i) +1 }
  end

  def process(s, &combiner)
    s = sanitize(s)
    out = ""
    s.each_byte { |c|
      if c >= ?A and c <= ?Z
       key = @keystream.get
       res = combiner.call(c, key[0])
        out << res.chr
      else
        out << c.chr
      end
    }
    return out
  end

  def encrypt(s)
    return process(s) {|c, key| 64 + mod(c + key - 128)}
  end

  def decrypt(s)
    return process(s) {|c, key| 64 + mod(c -key)}
  end

end

class Deck

  def initialize
    @deck = (1..52).to_a.push("A","B")
  end

  def move_A
    move_down(@deck.index("A"))
  end

  def move_B
    2.times { move_down( @deck.index( 'B' ) ) }
  end

  def move_down(index)
    if index < 53
      new = index + 1
      @deck[new] , @deck[index] = @deck[new] , @deck[index] 
    else
      @deck = @deck[0,1] + @deck[-1,1] + @deck[1..-2]
      new = 1
    end
    return new
  end

  def triple_cut
    jokers = [@deck.index("A")],[@deck.index("B")]
    top,bottom = jokers.min,jokers.max
    @deck = @deck[(bottom+1)..-1] + @deck[top..bottom] + @deck[0..top]
  end

  def number_value (x)
    return 53 if x =="A" || x == "B"
    return x
  end

  def count_cut
    value = number_value(@deck[-1])
    @deck = @deck[value..-2] + @deck[0,value] + @deck[-1,1]
  end

  def output_letter
    a = @deck.first
    a = 53 if a == "A" || a == "B"
    output = @deck[a]
    if output == "A" || a == "B"
      nil
    else
      output -= 26 if output > 26
      (output +64).chr
    end
  end

  def shuffle(init, method = :fisher_yates)
    srand(init)
    self.send(method.id2name + "_shuffle",@deck)
  end


  private

  def fisher_yates_shuffle(a)
    (a.size -1 ).downto(0) { |i|
      j = rand(i+1)
      a[i],a[j] = a[j],a[i] if i != j
    }
  end

  def naive_shuffle(a)
    for i in 0..a.size
      j = rand(a.size)
      a[i],a[j] = a[j],a[i]
    end
  end


  # Generates a keystream for the given +length+.
  def generate_keystream(length)
    deck = @deck.dup
    result = []
    while result.length != length
      deck.move_A
      deck.move_B
      deck.triple_cut
      deck.count_cut
      letter = deck.output_letter
      result << letter unless letter.nil?
    end
      esult.join
  end

end

def test 
  d = Deck.new()
  d.generate_keystream
  puts d

  e = Encrypter.new(Deck.new())
  cipher = e.encrypt('Code in Ruby, live longer!')
  puts cipher

  e = Encrypter.new(Deck.new())
  puts e.decrypt(cipher)

  e = Encrypter.new(Deck.new())
  puts e.decrypt("CLEPK HHNIY CFPWH FDFEH")

  e = Encrypter.new( Deck.new() )
  puts e.decrypt("ABVAW LWZSY OORYK DUPVH")
end

puts a = sanitize("we 4ser3 242F25MEBqev234")
puts letter_to_number(a)
puts deck = (1..52).to_a.push("A","B")
  

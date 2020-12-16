require 'json'

class Word
    attr_reader :word

    def initialize(word=1)
        @word = word
    end

    def rand_word()
        dictionary = File.read('5desk.txt')
    
        array = dictionary.split(' ')
        while true 
            guess_word = array.sample
            if guess_word.length > 4 && guess_word.length < 13
                @word = guess_word
                break
            else
                next
            end
        end
    end

    def good_letter?(guess)

        word_array = @word.split('')

        if word_array.include?(guess)
            return true
        else
            return false
        end
    end

    def win?(correct)
        word_array = word.split('')
        check = false
        word_array.each {|letter|
            if correct.include?(letter)
                check = true
            else
                check = false
                break
            end
        }
        return check
    end

end

class Player
    attr_reader :attempts, :current_correct, :word_save

    def initialize(attempts=0,current_incorrect=[],current_correct=[],word_save=nil)
        @attempts = attempts
        @current_correct = current_correct
        @current_incorrect = current_incorrect
        @word_save = word_save
    end

    def guess()
        p "Guess a letter or save."
        input = gets.chomp
    
        @attempts += 1
        return input
    end

    def log_guess(guess,state)
        if state == true
            @current_correct << guess
        else
            @current_incorrect << guess
        end
    end

    def display(word)
        p @current_incorrect

        word_array = word.split('')
        word_display = []
        word_array.each {|letter|
            if @current_correct.include?(letter)
                word_display << letter
            else
                word_display << "_"
            end
        }
        p word_display.join('')
    end

    def win()
        p "You won in #{@attempts} attempts!"
    end

    def lose()
        p "You lost."
    end

    def save_game(word)
        string = JSON.dump ({
            :word => word,
            :current_correct => @current_correct,
            :current_incorrect => @current_incorrect,
            :attempts => @attempts
        })
        save = File.open("save_game.txt","w")

        save.puts string
        save.close()
    end

    def self.load_game()
        file = File.open("save_game.txt","r")
        data = JSON.load file

        self.new(data['attempts'],data['current_incorrect'],data['current_correct'],data['word'])
    end


end

def start()
    p "New or Load"
    input = gets.chomp
    return input
end

def game()
    start = start()
    if start == "New"            
        word = Word.new()
        player = Player.new()
        word.rand_word()
    elsif start == "Load"
        player = Player.load_game()
        word = Word.new(player.word_save)
    end

    while true
        player.display(word.word)

        guess = player.guess()
        if guess == "save"
            player.save_game(word.word)
            break
        end

        letter_check = word.good_letter?(guess)
        player.log_guess(guess,letter_check)

        wins = word.win?(player.current_correct)

        if wins
            player.win()
            break
        elsif player.attempts>(word.word.length + 3)
            player.lose()
            break
        end
    end
end

game()
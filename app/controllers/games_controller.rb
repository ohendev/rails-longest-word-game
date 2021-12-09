require 'open-uri'
require 'json'

class GamesController < ApplicationController
  
  def new
    @letters = letters
    @startTime = Time.now
  end

  def score
    startTime = params[:time].to_datetime
    endTime = Time.now
    @timeElapsed = endTime - startTime
    if params[:word].nil?
      @alert = "You have forgotten to type a word!"
    else
      @score = calculateScore(params[:word], @timeElapsed)
    end
  end

  private

  def letters
    return ('A'..'Z').to_a.sample(9).join(" ")
  end

  def calculateScore(word, timeElapsed) 
    lettersArray = letters.split(" ").map { |letter| letter.downcase }
    word_uses_letters = checkLetters(word, lettersArray)
    dictionary_result = parse_attempt(word)
    result = build_result(word, word_uses_letters, dictionary_result)
    score = set_score(result, timeElapsed)
  end

  def checkLetters(word, lettersArray)
    return false if word.length > lettersArray.length

    word.chars.each do |letter|
      return false unless lettersArray.include?(letter)
    end
    return true
  end

  def parse_attempt(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    dictionary_serialized = URI.open(url).read
    dictionary_result = JSON.parse(dictionary_serialized)
    return dictionary_result
  end

  def build_result(word, word_uses_letters, dictionary_result)
    if word_uses_letters
      if dictionary_result["found"]
        return { message: "WELL DONE!", score: dictionary_result["length"] }
      else
        return { message: "#{word} is not an english word", score: 0 }
      end
    else
      return { message: "#{word} is not in the grid", score: 0 }
    end
  end

  def set_score(result, time)
    if result[:score].positive?
      return (result[:score]**5) / time
    else
      return 0
    end
  end
end

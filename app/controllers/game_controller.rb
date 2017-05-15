require 'open-uri'
require 'json'


class GameController < ApplicationController

  # def score
  #   start_time = Time.parse(params[:start_time])
  #   end_time = Time.now

  #    # @result = run_game(@attempt, grid, start_time, end_time)
  # end

  def game
    @grid = Array.new(15) { ('A'..'Z').to_a[rand(26)] }
    @start_time = Time.now
  end


  def score
    # Retrieve all game data from form
    @grid = params[:grid].split("")
    @attempt = params[:attempt]
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end



  private


  def included?(guess, grid)
    guess.split("").all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)

  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }


    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
    attempt, result[:translation], grid, result[:time])
    result
  end

  def score_and_message(attempt, translation, grid, time)
    if translation
    if included?(attempt.upcase, grid)
        score = compute_score(attempt, time)
        [0, "WP !"]
      else
        [0, "not a correct word"]
      end
    else
      [0, "not in the grid"]
    end
  end

def get_translation(word)
  api_key = "41906cee-ad5d-4b93-8d31-128e9207f1bd"
  begin
    response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
    json = JSON.parse(response.read.to_s)
    if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
      return json['outputs'][0]['output']
    end
  rescue
    if File.read('/usr/share/dict/words').upcase.split("\n").include? word.split.join(' ').upcase
      return word
    else
      return nil
    end
  end
end


end

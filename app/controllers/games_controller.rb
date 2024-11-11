require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...10).map { (65 + rand(26)).chr}
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @guess = params[:guess]
    @letters = params[:letters].split
    @start_time = Time.new(params[:start_time])

    received_json = URI.parse("https://dictionary.lewagon.com/#{@guess}").read
    response = JSON.parse(received_json)
    @result = {}

    if pass_grid_check?(@guess, @letters)
      @result = hit_api(response, @end_time - @start_time, @guess)
    else
      @result = { time: 0, score: 0, message: "Sorry, but #{@guess.capitalize} can't be built out of #{@letters}" }
    end

  end

  def pass_grid_check?(attempt, grid)
    attempt_chars = attempt.downcase.chars
    grid_chars = grid.join.downcase.chars
    return attempt_chars.all? { |char| grid_chars.count(char) >= attempt_chars.count(char) }
  end

  def hit_api(response, time_elasped, attempt)
    if response["found"]
      result = { time: time_elasped, score: attempt.length / time_elasped, message: "Congratulations! #{@guess.capitalize} is a valid English word!" }
    else
      result = { time: time_elasped, score: 0, message: "Sorry, but #{@guess.capitalize} does not seem to be a valid English word..." }
    end
    return result
  end

end

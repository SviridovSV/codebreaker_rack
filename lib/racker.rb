require 'erb'
require 'codebreaker'
require 'yaml'
require 'pry'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  attr_reader :win_game, :agree_to_save

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session[:game] ||= Codebreaker::Game.new
    @win_game = false
    @agree_to_save = false
    guesses
    results
  end

  def response
    case @request.path
      when '/' then index
      when '/new_game' then init_new_game
      when '/check_input' then check
      when '/show_hint' then show_hint
      when '/save_result' then save_result
    else
      Rack::Response.new('Not Found', 404)
    end
  end

  def index
    Rack::Response.new(render('index.html.erb'))
  end

  def game_do
    @request.session[:game]
  end

  def init_new_game
    @request.session[:game] = Codebreaker::Game.new
    Rack::Response.new do |response|
        response.set_cookie("guesses", [])
        response.set_cookie("results", [])
        response.set_cookie("hint", nil)
        response.redirect("/")
    end
  end

  def check
    result = game_do.check_input(@request.params['guess'])
    @win_game = true if result == "++++"
    unless @request.params["guess"] == ""
      result.empty? ? @results.push('mishit') : @results.push(result)
      @guesses.push(@request.params['guess'])
      Rack::Response.new do |response|
          response.set_cookie("guesses", @guesses)
          response.set_cookie("results", @results)
          response.redirect("/")
      end
    else
      Rack::Response.new do |response|
        response.redirect("/")
      end
    end
  end

  def guesses
    @guesses = @request.cookies['guesses'] || []
    @guesses = @guesses.split('&') unless @guesses.is_a? Array
  end

  def results
    @results = @request.cookies["results"] || []
    @results = @results.split('&') unless @results.is_a? Array
  end

  def hint
    @request.cookies["hint"]
  end

  def show_hint
    Rack::Response.new do |response|
      response.set_cookie("hint", game_do.hint_answer)
      response.redirect("/")
    end
  end

  def save_result
    name = @request.params["name"]
    File.open("score.yml", 'a') { |f| f.write(YAML.dump("#{name}; #{Codebreaker::Game::ATTEMPT_NUMBER - game_do.available_attempts}; #{Time.now.strftime("%d-%m-%Y %R")};")) }
    @agree_to_save = true
    Rack::Response.new do |response|
      response.redirect("/")
    end
  end

  def load_score
    file = File.open('score.yml')
    saved_score = []
    score = YAML::load_documents(file) do |doc|
      saved_score.push  doc.split(";")
    end
    saved_score
  end

  def no_attempts?
    game_do.available_attempts.zero?
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
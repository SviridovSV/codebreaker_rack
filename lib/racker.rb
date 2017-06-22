require 'erb'
require 'codebreaker'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    init_game
    guesses
    results
  end

  def response
    case @request.path
      when '/' then index
      when '/new_game' then init_game(true)
      when '/check_input' then check
      when '/show_hint' then show_hint
  end

  def index
    Rack::Response.new(render('index.html.erb')
  end

  def check
    result = @game.check_input(@request.params['guess'])
    unless @request.params["guess"] == ""
      @results.push(result)
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

  def show_hint

  end

  def guesses
    @guesses = @request.cookies['guesses'] || []
    @guesses = @guesses.split('&') unless @guesses.is_a? Array
  end

  def results
    @results = @request.cookies["results"] || []
    @results = @results.split('&') unless @results.is_a? Array
  end

  def init_game(next_game = false)
    @game = if next_game
      @request.session[:game] = prepare_game
      Rack::Response.new do |response|
        response.set_cookie("guesses", [])
        response.set_cookie("results", [])
        response.set_cookie("hint", nil)
        response.redirect("/")
      end
    else
      @request.session[:game] ||= prepare_game
    end

    def prepare_game
      game = Codebreaker::Game.new
      game.start
    end
  end
end
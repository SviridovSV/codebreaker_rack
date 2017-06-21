require './lib/racker'

use Rack::Reloader
use Rack::Static, :urls => ["/stylesheets"], :root => "public"
use Rack::Session::Cookie, :key => 'rack.session',
                           :secret => 'secret'
run Racker
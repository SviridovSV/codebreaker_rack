
require 'rack/test'
require_relative '../lib/racker'

describe Racker do
  include Rack::Test::Methods

  context '/' do
    let(:env) { { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/', 'rack.session' =>  { 'session_id' => 'test' } } }
    let(:app) { Racker.new(env) }
    let(:response) { Racker.call(env) }
    let(:status)   { response[0] }

    it 'returns the status 200' do
      expect(status).to eq 200
    end
  end

  context '/check_input' do
    let(:env) { { 'REQUEST_METHOD' => 'POST', 'PATH_INFO' => '/check_input', 'rack.input' => StringIO.new, 'rack.session' =>  { 'session_id' => 'test' } } }
    let(:app) { Racker.new(env) }
    let(:response) { Racker.call(env) }
    let(:status)   { response[0] }

    it 'returns the status 302' do
      expect(status).to eq 302
    end

    it 'changes location to /' do
      expect(response[1]['Location']).to eq '/'
    end
  end

  context '/show_hint' do
    let(:env) { { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/show_hint', 'rack.session' =>  { 'session_id' => 'test' } } }
    let(:app) { Racker.new(env) }
    let(:response) { Racker.call(env) }
    let(:status)   { response[0] }

    it 'returns the status 200' do
      expect(status).to eq 302
    end

    it 'changes location to /' do
      expect(response[1]['Location']).to eq '/'
    end
  end

  context '/new_game' do
    let(:env) { { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/new_game', 'rack.session' =>  { 'session_id' => 'test' } } }
    let(:app) { Racker.new(env) }
    let(:response) { Racker.call(env) }
    let(:status)   { response[0] }

    it 'returns the status 200' do
      expect(status).to eq 302
    end

    it 'changes location to /' do
      expect(response[1]['Location']).to eq '/'
    end
  end

  context '/save_result' do
    let(:env) { { 'REQUEST_METHOD' => 'POST', 'PATH_INFO' => '/save_result', 'rack.input' => StringIO.new, 'rack.session' => { 'session_id' => 'test' } } }
    let(:response) { Racker.call(env) }
    let(:status)   { response[0] }

    it 'returns the status 200' do
      expect(status).to eq 302
    end

    it 'changes location to /' do
      expect(response[1]['Location']).to eq '/'
    end
  end
end
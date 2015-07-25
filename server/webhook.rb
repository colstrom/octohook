require 'sinatra'
require 'json'
require_relative 'lib/webhook'

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  erb :index
end

include Payloads::GitHub

post '/payload/?' do
  return 403 unless valid_signature?
  event = request.env.fetch('HTTP_X_GITHUB_EVENT', 'default').to_sym
  handler = Events::GitHub
  payload = JSON.parse request.body.read
  handler.method(event).call(payload) if handler.methods.include? event
end

get '/changes/?:head?/?:base?/?' do
  head = params.fetch 'head', Git.repository.head.target.oid
  return 404 unless Git.repository.exists? head

  base = params.fetch 'base', Git.repository.lookup(head).parents.first.oid
  return 404 unless Git.repository.exists? base

  JSON.dump Git.changed_components(head, base)
end

get '/head/?' do
  JSON.dump Git.repository.head.target.oid
end

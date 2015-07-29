require 'sinatra'
require 'json'
require_relative 'lib/webhook'

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  erb :index
end

include GitHub::Payload

post '/payload/?' do
  return 403 unless valid_signature?
  event = request.env.fetch('HTTP_X_GITHUB_EVENT', 'default').to_sym
  handler = GitHub::Events
  payload = JSON.parse request.body.read
  handler.method(event).call(payload) if handler.methods.include? event
end

get '/changes/?:head?/?:base?/?' do
  head = params.fetch 'head', GitHub::Repository.head
  base = params.fetch 'base', GitHub::Repository.parent(head)
  changed_files = GitHub::Repository.changed_files head, base
  JSON.dump Components.changed changed_files
end

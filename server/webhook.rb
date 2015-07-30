require 'oj'
require 'sinatra'
require_relative 'lib/webhook'

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  erb :index
end

include GitHub::Payload

post '/payload/?' do
  return 403 unless valid_signature? || settings.development? || settings.test?
  request.body.rewind
  payload = Oj.load request.body.read
  handler = GitHub::Events
  event = request.env.fetch('HTTP_X_GITHUB_EVENT', 'default').to_sym
  handler.method(event).call(payload) if handler.methods.include? event
end

get '/changes/?:head?/?:base?/?' do
  head = params.fetch 'head', GitHub::Repository.head
  base = params.fetch 'base', GitHub::Repository.parent(head)
  changed_files = GitHub::Repository.changed_files head, base
  Oj.dump Components.changed changed_files
end

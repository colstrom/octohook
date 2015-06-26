require 'sinatra'
require 'json'
require 'octokit'

require_relative 'lib/github_payload'
require_relative 'lib/git_repository'

include GitHubPayload
include GitRepository

post '/payload/?' do
  return 403 unless valid_signature?
  handler = request.env.fetch('HTTP_X_GITHUB_EVENT', 'default').to_sym
  method(handler).call(JSON.parse request_body) if methods.include? handler
end

get '/changes/:commit/components/?' do
  JSON.dump changed_components params[:commit]
end

get '/changes/:commit/files/?' do
  JSON.dump changed_files params[:commit]
end

get '/head/?' do
  JSON.dump repository.head.target.oid
end

def pull_request(payload)
  puts payload
end

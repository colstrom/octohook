require 'sinatra'
require 'json'
require 'octokit'

require_relative 'lib/github_payload'

include GitHubPayload

post '/payload/?' do
  return 403 unless valid_signature?
  handler = request.env.fetch('HTTP_X_GITHUB_EVENT', 'default').to_sym
  method(handler).call if methods.include? handler
end

def pull_request
  payload = JSON.parse request_body
  puts payload
end

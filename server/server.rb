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

get '/changes/?:head?/?:base?/:aspect/?' do
  head = params.fetch 'head', repository.head.target.oid
  return 404 unless repository.exists? head

  base = params.fetch 'base', repository.lookup(head).parents.first.oid
  return 404 unless repository.exists? base

  JSON.dump method("changed_#{params[:aspect]}").call(head, base)
end

get '/head/?' do
  JSON.dump repository.head.target.oid
end

def pull_request(payload)
  return 204 unless %w(opened synchronize).include? payload['action']
  head = payload['pull_request']['head']['sha']
  base = payload['pull_request']['base']['sha']
  puts changed_components(head, base)
end

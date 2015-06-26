require 'sinatra'
require 'json'
require 'octokit'
require 'secure_compare'

ACCESS_TOKEN = ENV.fetch('GITHUB_SECRET').freeze

def request_signature
  request.env.fetch 'HTTP_X_GITHUB_EVENT', nil
end

def unsigned?
  request_signature.nil?
end

def request_body
  request.body.rewind.read
end

def body_signature
  digest = OpenSSL::Digest.new 'sha1'
  "sha1=#{OpenSSL::HMAC.hexdigest digest, GITHUB_SECRET, request_body}"
end

def valid_signature?
  return false if unsigned?
  SecureCompare.compare request_signature, body_signature
end

post '/payload/?' do
  return 403 unless valid_signature?
  handler = request.env['HTTP_X_GITHUB_EVENT'].to_sym
  method(handler).call if methods.include? handler
end

def pull_request
  payload = JSON.parse request_body
  puts payload
end

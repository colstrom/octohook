require 'sinatra'
require 'json'
require 'octokit'

ACCESS_TOKEN = ENV['ACCESS_TOKEN']

post '/payload' do
  # Check the token
  #client ||= Octokit::Client.new(:access_token => ACCESS_TOKEN)
  #user = client.user
  #user.login
  #puts "Client: #{user}"

  # Get the payload
  request.body.rewind
  payload_body = request.body.read

  verify_signature(payload_body, ACCESS_TOKEN)
  puts "Signature verified!"

  # @payload = JSON.parse(request.body.read)
  push = JSON.parse(params[:payload])
  puts "I got some JSON: #{push.inspect}"

  # Process the payload
  case request.env['HTTP_X_GITHUB_EVENT']

    # Process pull requests
    when "pull_request"
      if @payload["action"] == "opened"
        process_pull_request(@payload["pull_request"])
      #TODO: process @payload["action"] == "updated"
      end
    else process_other_request(@payload)
  end
end

# Function: Check the signature of the payload
def verify_signature(payload_body, secret_token)
  puts "Payload: #{payload_body}"
  puts "Token: #{secret_token}"

  hmac_digest = OpenSSL::Digest.new('sha1')
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(hmac_digest, secret_token, payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end

helpers do
  def process_pull_request(pull_request)
    puts "It's #{pull_request['title']}"
  end

  def process_other_request(request)
    puts "It's #{request}"
  end
end


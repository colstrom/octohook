require 'secure_compare'
require 'contracts'

GITHUB_SECRET = ENV.fetch('GITHUB_SECRET').freeze

# Module for handling GitHub payloads
module GitHubPayload
  include Contracts

  Contract nil => Maybe[String]
  def request_signature
    request.env['HTTP_X_HUB_SIGNATURE']
  end

  Contract nil => String
  def request_body
    request.body.rewind
    request.body.read
  end

  Contract nil => String
  def body_signature
    digest = OpenSSL::Digest::SHA1.new
    "sha1=#{OpenSSL::HMAC.hexdigest digest, GITHUB_SECRET, request_body}"
  end

  Contract nil => Bool
  def valid_signature?
    return false unless request_signature
    SecureCompare.compare request_signature, body_signature
  end
end

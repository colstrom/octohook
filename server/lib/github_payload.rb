require 'secure_compare'
require 'contracts'

GITHUB_SECRET = ENV.fetch('GITHUB_SECRET').freeze

module GitHubPayload
  include Contracts

  Contract nil => Maybe[String]
  def request_signature
    request.env.fetch 'HTTP_X_HUB_SIGNATURE', nil
  end

  Contract nil => String
  def request_body
    request.body.rewind
    request.body.read
  end

  Contract nil => String
  def body_signature
    digest = OpenSSL::Digest.new 'sha1'
    "sha1=#{OpenSSL::HMAC.hexdigest digest, GITHUB_SECRET, request_body}"
  end

  Contract nil => Bool
  def valid_signature?
    return false unless request_signature
    SecureCompare.compare request_signature, body_signature
  end
end

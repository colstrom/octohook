require 'contracts'
require 'fast_secure_compare/fast_secure_compare'

module GitHub
  # Mixin for handling GitHub payloads.
  module Payload
    include Contracts

    Contract None => Maybe[String]
    def request_signature
      request.env['HTTP_X_HUB_SIGNATURE']
    end

    Contract None => String
    def body_signature
      digest = OpenSSL::Digest::SHA1.new
      secret = ENV['GITHUB_SECRET']
      "sha1=#{OpenSSL::HMAC.hexdigest digest, secret, request.body.read}"
    end

    Contract None => Bool
    def valid_signature?
      return false unless request_signature
      FastSecureCompare.compare request_signature, body_signature
    end
  end
end

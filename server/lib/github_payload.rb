require 'secure_compare'

GITHUB_SECRET = ENV.fetch('GITHUB_SECRET').freeze

module GitHubPayload
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
end

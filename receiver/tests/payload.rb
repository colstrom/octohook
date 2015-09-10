#!/usr/bin/env ruby

require 'rspec'
require 'typhoeus'

describe 'HTTP POST to /' do
  let(:url) { 'http://localhost:9910/' }
  # let(:url) { 'https://receiver.indevops.com/' }
  let(:headers) do
    {
      'content-type' => 'application/json',
      'User-Agent' => "GitHub-HookShot/#{SecureRandom.hex 4}",
      'X-GitHub-Delivery' => SecureRandom.uuid,
      'X-Hub-Signature' => signature
    }
  end
  let(:request) do
    Typhoeus::Request.new url, method: :post, headers: headers, body: payload
  end
  let(:response) { request.run }
  let(:signature) do
    digest = OpenSSL::Digest::SHA1.new
    secret = ENV['GITHUB_SECRET']
    "sha1=#{OpenSSL::HMAC.hexdigest digest, secret, payload}"
  end

  context 'when :payload is a pull_request' do
    before { headers.update ({ 'X-GitHub-Event' => 'pull_request' }) }
    let(:payload) { File.read File.expand_path 'tests/fixtures/pull_request.json' }

    describe 'response.success?' do
      subject { response.success? }
      it { is_expected.to be true }
    end
  end
end

#!/usr/bin/env ruby

require 'rspec'
require 'typhoeus'

describe 'POST to /payload' do
  let(:url) { 'http://localhost:9292/payload' }
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

  context 'with a pull_request' do
    before { headers.update ({ 'X-GitHub-Event' => 'pull_request' }) }
    let(:payload) { File.read File.expand_path 'tests/fixtures/pull_request.json' }

    describe 'the response code' do
      subject { response.code }
      it { is_expected.to be 200 }
    end
  end
end

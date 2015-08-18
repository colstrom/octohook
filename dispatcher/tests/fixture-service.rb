#!/usr/bin/env ruby

require 'webmachine'

class Fixture < Webmachine::Resource
  def content_types_provided
    [['text/plain', :to_text]]
  end

  def to_text
    File.read File.expand_path "tests/fixtures/#{request.disp_path}"
  end
end

Webmachine.application.configure { |c| c.port = ENV.fetch 'PORT', 7777 }
Webmachine.application.routes { add [:*], Fixture }
Webmachine.application.run

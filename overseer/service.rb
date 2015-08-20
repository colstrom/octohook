#!/usr/bin/env ruby

require 'webmachine'
require_relative 'lib/overseer'

Webmachine.application.routes do
  add ['history'], Overseer::History
  add [:*], Overseer::Summary
end

Thread.new do
  manager = Manager.new
  loop { manager.manage }
end

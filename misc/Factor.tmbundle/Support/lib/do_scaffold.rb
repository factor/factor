#!/usr/bin/env ruby

require "#{ENV["TM_BUNDLE_SUPPORT"]}/lib/tm_factor"

path = ENV["TM_FILEPATH"]
if path.include?("factor/work") then
  s = "scaffold-work"
elsif path.include?("factor/basis") then
  s = "scaffold-basis"
elsif path.include?("factor/core") then
  s = "scaffold-core"
else
  s = "scaffold-extra"
end

puts factor_eval(%Q(USE: tools.scaffold\n "#{ARGV.first}" #{s}))
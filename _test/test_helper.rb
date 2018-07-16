#!/usr/bin/env ruby

require 'stringio'
require 'pp'

TestCase = begin
             tc = begin
                    gem 'minitest' rescue nil
                    require 'minitest/autorun'
                    case
                    when defined?(Minitest::Test) ; Minitest::Test
                    when defined?(Minitest::Unit::TestCase) ; Minitest::Unit::TestCase
                    end
                  rescue LoadError
                    # nop
                  end
             unless tc
               require "test/unit"
               tc = Test::Unit::TestCase
             end
             tc
           end

$:.unshift("#{File.dirname(__FILE__)}/../lib")
require 'exifr/jpeg'
require 'exifr/tiff'
include EXIFR

EXIFR.logger = Logger.new(StringIO.new)

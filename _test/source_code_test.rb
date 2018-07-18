#!/usr/bin/env ruby

require './test_helper'
require 'liquid.rb'
require 'jekyll'

require '../_plugins/source_code'

class SourceCodeTest < TestCase
  def test_parse
    template = Liquid::Template.parse('{% source_code ../_plugins/source_code.rb %}')
    assert_equal 'source_code', template.root.nodelist[0].tag_name
  end
end

#!/usr/bin/env ruby

require './test_helper'

class JPEGTest < TestCase

  def test_initialize
    images = { '../images/photography/munich/MUC2778.jpeg' => { 'model' => 'NIKON D7000',
                                                                'time' => Time.new(2017, 12, 21, 13, 13, 35, '+00:00') },
               '../images/photography/dublin/DSC_0851.JPG' => { 'model' => 'NIKON D60',
                                                                'time' => Time.new(2010, 9, 12, 12, 39, 17, "+01:00") } }

    images.each do |image, data|
      exif = EXIFR::JPEG.new(image)
      assert exif.exif?
      assert_equal exif.model, data['model']
      assert_equal 'date_time_original'.split('.').inject(exif){|o,m| o.send(m)}, data['time']
    end
  end
end

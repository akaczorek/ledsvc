#!/usr/bin/env ruby

require "rmagick"
require "securerandom"

mytext="Sample Text"

draw=Magick::Draw.new {
  self.font_family = 'Comic Sans MS'
  self.fill="#6495ED"
  self.pointsize = 16
  self.font_weight = 600
  self.gravity = Magick::SouthWestGravity
  }
metrics=draw.get_type_metrics(mytext)
image=Magick::Image.new(metrics['width']+30,16) { 
  self.background_color = "black" 
  self.format = "PPM"
  self.depth = 8
  }
draw.annotate(image,0,0,0,0,mytext) {
  self.font_family = 'Comic Sans MS'
  self.fill="#6495ED"
  self.pointsize = 16
  self.font_weight = 600
  self.gravity = Magick::SouthWestGravity
  }
outfile="/tmp/#{SecureRandom.uuid}.ppm"
image.write(outfile)
`curl -s -F "file=@#{outfile}" "http://localhost:8080/upload"`
File.delete(outfile)

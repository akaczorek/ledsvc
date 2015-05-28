#!/usr/bin/env ruby

require "rmagick"
require "hipchat"
require "json"
require "securerandom"
require "daemons"

$indextime=Time.at(0)

def setup()
  variables =%w{HIPCHAT_TOKEN HIPCHAT_ROOM}
  missing = variables.find_all { |v| ENV[v] == nil }
  unless missing.empty?
    puts "Missing #{missing.join(', ')}"
    exit 1
  end
end

def main()
  loop do
    begin
      client = HipChat::Client.new(ENV['HIPCHAT_TOKEN'])
    rescue => error
      puts error.inspect
      sleep 10
      retry
    end
    begin
      myjson=JSON.parse(client[ENV['HIPCHAT_ROOM']].history())
    rescue HipChat::UnknownResponseCode => error
      puts error.inspect
      sleep 10
      retry
    end
    myjson["messages"].each do |i|
      $newindextime=Time.parse(i["date"])
      unless $newindextime <= $indextime
        msg=i["message"]
        if msg =~ /hammer help/
          next
        end
        render i["from"]["name"] + ": " + fixer(i["message"])
      end
    end
    $indextime=$newindextime
    sleep 10
  end
end

def fixer (text)
  return text.gsub(/http\S*/, '<url>')
end


def render(mytext)
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
end

options = {
  :app_name => "hipchat",
  :dir_mode => :system
}

Daemons.run_proc(File.join(File.dirname(__FILE__), 'hipchat.rb'), options) do
  setup()
  main()
end

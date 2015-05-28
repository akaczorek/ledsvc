require 'bundler/setup'
Bundler.require(:default)
require File.expand_path('../lib/display', __FILE__)
require 'sinatra/redis'
require 'logger'
require 'rmagick'
require 'securerandom'

configure do
  redis_url = "redis://localhost:6379/"
  uri = URI.parse(redis_url)
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  Resque.redis.namespace = "resque:leddisplay"
  set :redis, redis_url
  file = File.new("/root/ledsvc/log/sinatra.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
  set :logging, Logger::DEBUG
end

get "/" do
@info = Resque.info
  erb :index
end

post '/upload' do
  enqueueImage(params['file'][:tempfile])
end

post '/display' do ||
  data = JSON.parse request.body.read
  generateImageFile(data['text'])
end

def enqueueImage(imageFileObject)
  unless imageFileObject.nil?
    outfile="/tmp/#{SecureRandom.uuid}.ppm"
    File.open(outfile, 'w') { |file| file.write(imageFileObject.read) }
    Resque.enqueue(Display, outfile)
  end
end

def generateImageFile(mytext)
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
  outfileObject = File.new(outfile, 'r')
  enqueueImage(outfileObject)
  outfileObject.close()
  File.delete(outfile)
end


require 'bundler/setup'
Bundler.require(:default)
require File.expand_path('../lib/display', __FILE__)
require 'sinatra/redis'
require 'logger'

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
  unless params['file'][:tempfile].nil?
    tmpfile = params['file'][:tempfile]
    outfile="/tmp/#{SecureRandom.uuid}.ppm"
    File.open(outfile, 'w') { |file| file.write(params[:file][:tempfile].read) }
    Resque.enqueue(Display, outfile)
  end
end


require 'bundler/setup'
Bundler.require(:default)

require './sinatra'
require 'resque/tasks'

task "resque:setup" do
      ENV['QUEUE'] = '*'
end

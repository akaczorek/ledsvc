require 'resque/errors'
require 'sinatra/redis'

config = {
  folder:     "/root/ledsvc/log", 
  class_name: Logger,
  level:      Logger::DEBUG,
  formatter:  Logger::Formatter.new
}

Resque.logger_config = config

module RetriedJob
  def on_failure_retry(e, *args)
    logger.error "Performing #{self} caused an exception (#{e}). Retrying..."
    Resque.enqueue self, *args
  end
end

class Display
  extend RetriedJob
  extend Resque::Plugins::Logger

  @queue = :leddisplay

  def self.perform(localpath)
    logger.info "displaying #{localpath}"
    system("/root/ledsvc/led-matrix","-r16","-D1","-t60","#{localpath}")
    File.delete(localpath)
  rescue Resque::TermException
    logger.error "display #{localpath} failed"
    Resque.enqueue(self, localpath)
  end

end

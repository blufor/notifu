require_relative "sidekiq_init"

$logger = Notifu::Logger.new 'actor'

Sidekiq.configure_server do |config|
  config.redis = { url: Notifu::CONFIG[:redis_queues] }
  Sidekiq::Logging.logger = Log4r::Logger.new 'sidekiq'
  Sidekiq::Logging.logger.outputters = Log4r::SyslogOutputter.new 'sidekiq', ident: 'notifu-actor'
  # Sidekiq::Logging.logger.formatter = Notifu::LogFormatter.new
  Sidekiq::Logging.logger.level = Log4r::DEBUG
end

Sidekiq.configure_client do |config|
  config.redis = { url: Notifu::CONFIG[:redis_queues] }
end


module Notifu

  class Actor
    include Notifu::Util
    include Sidekiq::Worker

    require 'erb'
    require 'ostruct'

    attr_accessor :issue
    attr_accessor :contacts

    class << self
      attr_accessor :name
      attr_accessor :desc
      attr_accessor :retry
    end

    # `act` function must be defined in child classes
    # (provides notification actors modularity)
    #
    def act
      exit 1
    end

    sidekiq_options :queue => "actor-#{self.name}"
    sidekiq_options :retry => self.retry

    def perform *args
      sleep 1
      load_data args || return
      act
    end

    def load_data args
      self.issue = Notifu::Model::Issue.with(:notifu_id, args[0])
      if self.issue == nil
        log "error", "Issue with NID #{args[0]} doesn't exist!"
        return false
      end
      self.contacts = Array.new
      args[1].each do |contact|
        c = Notifu::Model::Contact.with(:name, contact)
        self.contacts << c if c
      end
      return true
    end

    def apply_template t
      @data ||= OpenStruct.new({
        notifu_id: self.issue.notifu_id,
        datacenter: self.issue.datacenter,
        host: self.issue.host,
        service: self.issue.service,
        status: self.issue.code.to_state,
        code: self.issue.code.to_s,
        message: self.issue.message,
        first_event: Time.at(self.issue.time_created.to_i),
        duration: (Time.now.to_i - self.issue.time_created.to_i).duration,
        interval: self.issue.interval.duration,
        refresh: self.issue.refresh.duration,
        occurrences_count: self.issue.occurrences_count,
        occurrences_trigger: self.issue.occurrences_trigger,
        uchiwa_url: "#{Notifu::CONFIG[:uchiwa_url]}/#/client/#{self.issue.datacenter}/#{self.issue.host}?check=#{self.issue.service}",
        playbook: self.issue.playbook
      })
      begin
        ERB.new(t).result(@data.instance_eval { binding })
      rescue Exception => e
        log "error", "Failed to render ERB template - #{e.class}: #{e.message}"
        ERB.new(default_template).result(@data.instance_eval {binding})
      end
    end

    def default_template
      "<%= status %> [<%= dc %>/<%= host %>/<%= service %>]: (<%= message %>) <%= duration %> [<%= notifu_id %>]"
    end

  end
end

# load all actors
Dir[File.dirname(__FILE__).sub(/\/workers$/, "/") + 'actors/*.rb'].each do |file|
  require file
end

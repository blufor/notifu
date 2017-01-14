module Notifu
  module Util

    def self.option args
      self.instance_variable_set args.keys.first, args.values.first
    end

    def self.log(prio, msg)
      $logger.log prio, "JID-#{self.jid}: " + msg.to_s
    end

    def self.action_log event(worker)
      $logger.action_log worker, event
    end


  end
end

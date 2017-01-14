module Notifu
  module Actors
    class Pagerduty < Notifu::Actor

      require 'excon'

      self.name = "pagerduty"
      self.desc = "Sends event to pagerduty"
      self.retry = 3

      def post_data(type, service_id)
        {
          service_key: service_id,
          event_type: type,
          description: self.text,
          incident_key: self.issue.notifu_id,
          details: {
            host: self.issue.host,
            address: self.issue.address,
            service: self.issue.service,
            message: self.issue.message,
            status: self.issue.code.to_state,
            datacenter: self.issue.datacenter,
            first_event: Time.at(self.issue.time_created.to_i),
          },
          client: "Sensu",
          client_url: "#{Notifu::CONFIG[:uchiwa_url]}/#/client/#{self.issue.datacenter}/#{self.issue.host}?check=#{self.issue.service}"
        }
      end

      def text(c)
        t = c.pagerduty_template
        t ||= self.default_template
        self.apply_template t
      end


      def act
        type = "resolve" if self.issue.code.to_i == 0
        type ||= "trigger"

        self.contacts.each do |contact|
          contact.pagerduty_id || next

          begin
            Excon.post(Notifu::CONFIG[:actors][:pagerduty][:url],
              tcp_nodelay: true,
              headers: { "ContentType" => "application/json" },
              body: self.post_data(type, c).to_json,
              expects: [ 200 ],
              idempotent: true,
            )
          rescue Exception => e
            log "error", "Failed to send event to PagerDuty - #{e.class}: #{e.message}"
          end
        end
      end

    end
  end
end

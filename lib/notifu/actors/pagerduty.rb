module Notifu
  module Actors
    class Pagerduty < Notifu::Actor

      require 'excon'
      require 'erb'

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
            status: self.issue.code.to_state,
            dc: self.issue.datacenter,
            host: self.issue.host,
            service: self.issue.service,
            message: self.issue.message,
            first_event: Time.at(self.issue.time_created.to_i),
          },
          client: "Sensu",
          client_url: "#{Notifu::CONFIG[:uchiwa_url]}/#/client/#{self.issue.datacenter}/#{self.issue.host}?check=#{self.issue.service}"
        }
      end

      def text
        data = OpenStruct.new({
          notifu_id: self.issue.notifu_id,
          datacenter: self.issue.datacenter,
          host: self.issue.host,
          service: self.issue.service,
          message: self.issue.message,
          status: self.issue.code.to_state
        })
        ERB.new(self.template).result(data.instance_eval {binding})
      end

      def template
        "<%= data[:status] %> [<%= data[:datacenter] %>/<%= data[:host] %>/<%= data[:service] %>]: <%= data[:message] %>"
      end

      def act
        type = "resolve" if self.issue.code.to_i == 0
        type ||= "trigger"

        self.contacts.each do |contact|
          begin
            c = contact.pagerduty_id
          rescue
            c = false
          end

          Excon.post(Notifu::CONFIG[:actors][:pagerduty][:url],
            tcp_nodelay: true,
            headers: { "ContentType" => "application/json" },
            body: self.post_data(type, c).to_json,
            expects: [ 200 ],
            idempotent: true,
          ) if c
        end
      end

    end
  end
end

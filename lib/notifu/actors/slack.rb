module Notifu
  module Actors
    class Slack < Notifu::Actor

      require 'excon'
      require 'erb'

      self.name = "slack"
      self.desc = "Notifies to Slack channel via Webhook"
      self.retry = 3

      def post_data(rich)
        return {
          username: "notifu",
          icon_emoji: ":loudspeaker:",
          attachments: [
            {
              fallback: self.text,
              color: self.color,
              title: "#{self.issue.host} - #{self.issue.service}",
              title_link: "#{Notifu::CONFIG[:uchiwa_url]}/#/client/#{self.issue.datacenter}/#{self.issue.host}?check=#{self.issue.service}",
              text: self.issue.message,
              fields: [
                {
                  title: "duration",
                  value: (Time.now.to_i - self.issue.time_created.to_i).duration,
                  short: true
                },
                {
                  title: "notifu ID",
                  value: self.issue.notifu_id,
                  short: true
                }
              ]
            }
          ]
        }.to_json if rich
        {
          username: "notifu",
          icon_emoji: ":loudspeaker:",
          text: self.text
        }.to_json
      end

      def color
        case self.issue.code.to_i
        when 0
          "good"
        when 1
          "warning"
        when 2
          "danger"
        else
          "#999999"
        end
      end

      # fallback simple message (templated, see below)
      def text
        data = OpenStruct.new({
          notifu_id: self.issue.notifu_id,
          datacenter: self.issue.datacenter,
          host: self.issue.host,
          service: self.issue.service,
          message: self.issue.message,
          status: self.issue.code.to_state,
          first_event: Time.at(self.issue.time_created.to_i),
          duration: (Time.now.to_i - self.issue.time_created.to_i).duration,
          occurrences_count: self.issue.occurrences_count,
          occurrences_trigger: self.issue.occurrences_trigger,
          uchiwa_url: "#{Notifu::CONFIG[:uchiwa_url]}/#/client/#{self.issue.datacenter}/#{self.issue.host}?check=#{self.issue.service}"
        })
        ERB.new(self.template).result(data.instance_eval {binding})
      end

      # template for fallback message
      def template
        "**<%= data[:status] %>** [<<%= data[:uchiwa_url] %>|<%= data[:datacenter]%>/<%= data[:host] %>/<%= data[:service] %>>]: <%= data[:message] %> (<%= data[:duration] %>)"
      end

      def act
        self.contacts.each do |contact|
          begin
            data = { channel: contact.slack_id }.merge(self.post_data(contact.slack_rich))
          rescue
            data = self.post_data
          end
          Excon.post(contact.slack_url,
            tcp_nodelay: true,
            headers: { "ContentType" => "application/json" },
            body: data,
            expects: [ 200 ],
            idempotent: true
          )
        end
      end

    end
  end
end

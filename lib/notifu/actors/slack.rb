module Notifu
  module Actors
    class Slack < Notifu::Actor

      require 'excon'
      require 'erb'

      self.name = "slack"
      self.desc = "Notifies to Slack channel via Webhook"
      self.retry = 3

      def post_data(rich = false)
        return {
          username: "notifu",
          icon_emoji: ":loudspeaker:",
          attachments: [
            {
              fallback: self.text(self.fallback_template),
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
        } if rich
        return {
          username: "notifu",
          icon_emoji: ":loudspeaker:",
          text: self.text(self.template)
        }
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

      def status_icon
        return @status_icon if defined? @status_icon
        case self.issue.code.to_i
        when 0
          @status_icon = ":white_check_mark:"
        when 1
          @status_icon = ":exclamation:"
        when 2
          @status_icon = ":bangbang:"
        else
          @status_icon = ":question: _#{self.issue.code.to_s}_"
        end
        @status_icon
      end

      def service_icon
        return @service_icon if defined? @service_icon
        @service_icon = ":computer:" if self.issue.service == "keepalive"
        @service_icon ||= ":gear:"
      end

      # fallback simple message (templated, see below)
      def text(tmpl)
        data = OpenStruct.new({
          notifu_id: self.issue.notifu_id,
          datacenter: self.issue.datacenter,
          host: self.issue.host,
          address: self.issue.address,
          service: self.issue.service,
          message: self.issue.message,
          status: self.issue.code.to_state,
          duration: (Time.now.to_i - self.issue.time_created.to_i).duration,
          uchiwa_url: "#{Notifu::CONFIG[:uchiwa_url]}/#/client/#{self.issue.datacenter}/#{self.issue.host}?check=#{self.issue.service}",
          service_icon: self.service_icon,
          status_icon: self.status_icon
        })
        ERB.new(tmpl).result(data.instance_eval {binding})
      end

      # template for fallback message
      def fallback_template
        "*<%= data[:status] %>* <%= data[:datacenter]%> <%= data[:host] %> <%= data[:service] %> - <%= data[:message] %> (<%= data[:duration] %>) <%= data[:uchiwa_url] %>"
      end

      # template for plain message
      def template
        "<%= data[:status_icon] %> *<<%= data[:uchiwa_url] %>|<%= data[:datacenter] %>/<%= data[:host] %>>* <%= data[:address] %> <%= data[:service_icon] %> *<%= data[:service] %>* - <%= data[:message] %> _<%= data[:duration] %>_"
      end

      def act
        self.contacts.each do |contact|
          begin
            data = { channel: contact.slack_id }.merge(self.post_data(contact.slack_rich)) if contact.slack_rich
            data ||= { channel: contact.slack_id }.merge(self.post_data)
          rescue
            data = self.post_data
          end
          puts data.to_yaml
          Excon.post(Notifu::CONFIG[:actors][:slack][:url],
            tcp_nodelay: true,
            headers: { "ContentType" => "application/json" },
            body: data.to_json,
            expects: [ 200 ],
            idempotent: true
          )
        end
      end

    end
  end
end

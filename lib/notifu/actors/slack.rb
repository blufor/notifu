module Notifu
  module Actors
    class Slack < Notifu::Actor

      require 'excon'

      self.name = "slack"
      self.desc = "Notifies to Slack channel via Webhook"
      self.retry = 3

      def post_data(template, rich)
        return {
          username: "notifu",
          icon_emoji: ":loudspeaker:",
          attachments: [
            {
              fallback: self.apply_template(self.fallback_template),
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
        } if rich != nil

        template ||= self.default_template
        return { username: "notifu", icon_emoji: ":loudspeaker:", text: self.text }
      end

      def text(c)
        t = c.slack_template
        t ||= self.default_template
        self.apply_template t
      end

      def default_template
        "#{self.status_icon} *<<%= uchiwa_url %>|<%= datacenter %>/<%= host %>>* <%= address %> #{self.service_icon} *<%= service %>* - <%= message %> _<%= duration %>_"
      end

      def fallback_template
        "<%= status %> | <%= datacenter%>/<%= host %>/<%= service %> - <%= message %>"
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

      def act
        self.contacts.each do |contact|
          if contact.slack_id != nil
            data = self.post_data(contact.slack_template, contact.slack_rich).merge({ channel: contact.slack_id })
          else
            data = self.post_data(contact.slack_template, contact.slack_rich)
          end

          begin
            Excon.post(Notifu::CONFIG[:actors][:slack][:url],
              tcp_nodelay: true,
              headers: { "ContentType" => "application/json" },
              body: data.to_json,
              expects: [ 200 ],
              idempotent: true
            )
          rescue Exception => e
            log "error", "Failed to send message to Slack - #{e.class}: #{e.message}"
          end
        end
      end

    end
  end
end

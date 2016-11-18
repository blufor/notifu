module Notifu
  module Actors
    class SlackMsg < Notifu::Actor

      require 'excon'
      require 'erb'

      self.name = "slack_msg"
      self.desc = "Sends message to a Slack contact"
      self.retry = 3


      def act
        cfg = Notifu::CONFIG[:actors][:slack]
        contacts = self.contacts.map { |contact| contact.cell }
        req_string = Notifu::CONFIG[:actors][:twilio_call][:api] +
                      "?token="       + Notifu::CONFIG[:actors][:twilio_call][:token] +
                      "&status="      + self.issue.code.to_state +
                      "&hostname="    + self.issue.host +
                      "&service="     + self.issue.service +
                      "&description=" + ERB::Util.url_encode(self.issue.message.to_s) +
                      "&call_group="  + ERB::Util.url_encode(contacts.to_json) +
                      "&init=1"
        Excon.get req_string if self.issue.code.to_i == 2
      end

    end
  end
end

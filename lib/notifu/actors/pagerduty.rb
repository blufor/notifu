module Notifu
  module Actors
    class Pagerduty < Notifu::Actor

      require 'excon'
      require 'erb'

      self.name = "pagerduty"
      self.desc = "Sends event to pagerduty"
      self.retry = 3

      def template
        "<%= data[:status] %> [<%= data[:host] %>/<%= data[:service] %>]: <%= data[:message] %> (<%= data[:duration] %>) NID:<%= data[:notifu_id] %>]"
      end

      def post_data
        {
          text: self.text,
          username: "notifu",
          icon_emoji: self.emoji
        }.to_json
      end

      def text
        data = OpenStruct.new({
          notifu_id: self.issue.notifu_id,
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

      def act
        self.contacts.each do |contact|
          Excon.post(Notifu::CONFIG[:actors][:slack][:url],
            tcp_nodelay: true,
            headers: { "ContentType" => "application/json" },
            body: self.post_data,
            expects: [ 200 ],
            idempotent: true,
          )
        end
      end

    end
  end
end

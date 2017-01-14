module Notifu
  module Actors
    class GammuSmsBridge < Notifu::Actor

      self.name = "gammu_sms_bridge"
      self.desc = "Old-school NetCat-like SMS bridge to Gammu"
      self.retry = 3

      def act
        self.contacts.each do |contact|
          cell = contact.cell
          tmpl = contact.sms_template
          tmpl ||= default_template
          message = self.apply_template tmpl
          # send message to sms-bridge
          socket = TCPSocket.new Notifu::CONFIG[:actors][:gammu_sms_bridge][:host], Notifu::CONFIG[:actors][:gammu_sms_bridge][port]
          socket.send contact.cell.to_s + "--" + message
          socket.close
          socket = nil
        end
      end

    end
  end
end

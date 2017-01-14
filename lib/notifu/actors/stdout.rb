module Notifu
  module Actors
    class Stdout < Notifu::Actor

      self.name = "stdout"
      self.desc = "STDOUT notifier, useful for testing"
      self.retry = 0

      def act
        puts self.apply_template(self.default_template)
      end

    end
  end
end

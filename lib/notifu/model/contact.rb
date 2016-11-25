module Notifu
  module Model
    class Contact < Ohm::Model

      attribute :name
      attribute :full_name
      attribute :cell
      attribute :mail
      attribute :jabber
      attribute :slack_url
      attribute :pagerduty_url
      index :name
      unique :name

    end
  end
end

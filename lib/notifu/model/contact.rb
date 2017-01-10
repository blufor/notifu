module Notifu
  module Model
    class Contact < Ohm::Model

      attribute :name
      attribute :full_name
      attribute :cell
      attribute :mail
      attribute :slack_id
      attribute :slack_rich
      attribute :pagerduty_id
      index :name
      unique :name

    end
  end
end

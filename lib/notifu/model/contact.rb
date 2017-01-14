module Notifu
  module Model
    class Contact < Ohm::Model

      attribute :name
      attribute :full_name
      attribute :cell
      attribute :mail
      attribute :pagerduty_id
      attribute :pagerduty_template
      attribute :slack_id
      attribute :slack_rich
      attribute :slack_template
      attribute :sms_template
      index :name
      unique :name

    end
  end
end

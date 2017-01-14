module Notifu
  module Actors
    class Smtp < Notifu::Actor

      require 'mail'

      self.name = "smtp"
      self.desc = "SMTP notifier"
      self.retry = 2

      def act
        contacts = self.contacts.map { |contact| "#{contact.full_name} <#{contact.mail}>"}
        text_message = self.apply_template(self.text_template)
        html_message = self.apply_template(self.html_template)
        mail = Mail.new do
          from Notifu::CONFIG[:actors][:smtp][:from]
          subject "#{self.issue.code.to_state]}: #{self.issue.host]}/#{self.issue.service]}"
          to contacts
          text_part do
            body text_message
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            body html_message
          end
        end
        mail.delivery_method :sendmail
        mail.deliver
      end

      def text_template
        %{
<%= message %>

Notifu ID: <%= notifu_id %>
Host: <%= host %>
Service: <%= service %>
Status: <%= status %>
First event: <%= Time.at(first_event).to_s %>
Duration: <%= duration %>
Occurences: <%= occurrences_count %>/<%= occurrences_trigger %> (occured/trigger)
}
      end

      def html_template
        %{
<h3><%= message %></h3><br/>

<strong>Notifu ID: </strong><%= notifu_id %><br/>
<strong>Host: </strong><%= host %><br/>
<strong>Service: </strong><%= service %><br/>
<strong>Status: </strong><%= status %><br/>
<strong>First event: </strong><%= Time.at(first_event).to_s %><br/>
<strong>Duration: </strong><%= duration %><br/>
<strong>Occurences: </strong><%= occurrences_count %>/<%= occurrences_trigger %> (occured/trigger)<br/>
}
      end

    end
  end
end

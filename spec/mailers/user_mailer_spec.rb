# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'welcome' do
    subject(:mail) { ::UserMailer.with(email: 'email@example.com').welcome }

    it 'renders the headers' do
      expect(mail.to).to contain_exactly('email@example.com')

      expect(mail.subject).to be == 'To-do B/CDD - Welcome'
    end

    it 'renders the body' do
      url_to_sign_in = 'http://localhost:3000/users/sign_in'

      expect(mail.body.encoded).to match(
        "<p>To login to the app, just follow this link: <a href=\"#{url_to_sign_in}\">#{url_to_sign_in}</a>.</p>"
      )
    end
  end
end

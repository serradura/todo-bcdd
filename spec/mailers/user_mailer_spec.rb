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

  describe 'reset_password' do
    subject(:mail) { ::UserMailer.with(email:, reset_password_token:).reset_password }

    let(:email) { 'email@example.com' }
    let(:reset_password_token) { ::SecureRandom.uuid }

    it 'renders the headers' do
      expect(mail.to).to contain_exactly('email@example.com')

      expect(mail.subject).to be == 'To-do B/CDD - Reset password instructions'
    end

    it 'renders the body' do
      url_to_reset_password = "http://localhost:3000/users/reset_password/#{reset_password_token}"

      expect(mail.body.encoded).to match(
        "<a href=\"#{url_to_reset_password}\">Change my password</a>"
      )
    end
  end
end

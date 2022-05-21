# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::RegisterAndSendWelcomeEmail, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the email is blank' do
        let(:email) { [nil, '', ' '].sample }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }
        let(:password_confirmation) { password }

        it 'returns a failure result' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:validation_errors)
          expect(result.data.keys).to contain_exactly(:email, :errors)
        end

        it 'exposes the email' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:email]).to be_empty
        end

        it 'exposes errors' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:errors]).to have_attributes(
            itself: be_a(Hash),
            keys: contain_exactly(:email)
          )

          expect(result[:errors])
            .to match(hash_including(email: 'is invalid'))
        end
      end

      context 'when the email is invalid' do
        let(:email) { ' Foo' }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }
        let(:password_confirmation) { password }

        it 'returns a failure result' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:validation_errors)
          expect(result.data.keys).to contain_exactly(:email, :errors)
        end

        it 'exposes the email' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:email]).to be == 'foo'
        end

        it 'exposes errors' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:errors]).to have_attributes(
            itself: be_a(Hash),
            keys: contain_exactly(:email)
          )

          expect(result[:errors])
            .to match(hash_including(email: 'is invalid'))
        end
      end

      context 'when passwords are blank' do
        let(:email) { ' Foo@foo.com ' }
        let(:password) { [nil, '', ' '].sample }
        let(:password_confirmation) { [nil, '', ' '].sample }

        it 'returns a failure result' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:validation_errors)
          expect(result.data.keys).to contain_exactly(:email, :errors)
        end

        it 'exposes the email' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:email]).to be == 'foo@foo.com'
        end

        it 'exposes errors' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:errors]).to have_attributes(
            itself: be_a(Hash),
            keys: contain_exactly(:password, :password_confirmation)
          )

          expect(result[:errors]).to match(
            hash_including(
              password: "can't be blank",
              password_confirmation: "can't be blank"
            )
          )
        end
      end

      context 'when password is too short' do
        let(:email) { ::Faker::Internet.email.downcase }
        let(:password) { Faker::Alphanumeric.alpha(number: 5) }
        let(:password_confirmation) { Faker::Alphanumeric.alpha(number: 6) }

        it 'returns a failure result' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:validation_errors)
          expect(result.data.keys).to contain_exactly(:email, :errors)
        end

        it 'exposes the email' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:email]).to be == email
        end

        it 'exposes errors' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:errors]).to have_attributes(
            itself: be_a(Hash),
            keys: contain_exactly(:password, :password_confirmation)
          )

          expect(result[:errors]).to match(
            hash_including(
              password: 'is too short (minimum: 6)',
              password_confirmation: "doesn't match password"
            )
          )
        end
      end

      context 'when passwords are different' do
        let(:email) { ::Faker::Internet.email.downcase }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }
        let(:password_confirmation) { password.reverse }

        it 'returns a failure result' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:validation_errors)
          expect(result.data.keys).to contain_exactly(:email, :errors)
        end

        it 'exposes the email' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:email]).to be == email
        end

        it 'exposes errors' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:errors]).to have_attributes(
            itself: be_a(Hash),
            keys: contain_exactly(:password_confirmation)
          )

          expect(result[:errors])
            .to match(hash_including(password_confirmation: "doesn't match password"))
        end
      end

      context 'when email has already been taken' do
        let!(:user) { create(:user) }
        let!(:email) { user.email }
        let!(:password) { Faker::Alphanumeric.alpha(number: 6) }
        let!(:password_confirmation) { password }

        it 'returns a failure result' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:validation_errors)
          expect(result.data.keys).to contain_exactly(:email, :errors)
        end

        it 'exposes the email' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:email]).to be == email
        end

        it 'exposes errors' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:errors]).to have_attributes(
            itself: be_a(Hash),
            keys: contain_exactly(:email)
          )

          expect(result[:errors])
            .to match(hash_including(email: 'has already been taken'))
        end
      end
    end

    describe 'success' do
      context 'when email and password are valid' do
        include ActiveJob::TestHelper

        let(:email) { ::Faker::Internet.email.downcase }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }
        let(:password_confirmation) { password }

        it 'returns a succesful result' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result).to be_a_success
          expect(result.type).to be(:user_created)
          expect(result.data.keys).to contain_exactly(:user)
        end

        it 'exposes the user' do
          result = described_class.call(email:, password:, password_confirmation:)

          expect(result[:user])
            .to be_a(::User::Record)
            .and be_persisted
            .and have_attributes(email:)
        end

        it 'creates an user' do
          expect {
            described_class.call(email:, password:, password_confirmation:)
          }.to change { ::User::Record.count }.by(1)

          user = ::User::Record.last

          expect(user.email).to be == email
          expect(user.api_token.size).to be == 36
        end

        it 'sends an email in background' do
          expect {
            described_class.call(email:, password:, password_confirmation:)
          }.to(
            have_enqueued_job(ActionMailer::MailDeliveryJob)
              .on_queue('default')
              .with('UserMailer', 'welcome', any_args)
          )
        end
      end
    end
  end
end

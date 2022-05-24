# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Password::Reset::SendInstructions, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the email is blank' do
        let(:email) { [nil, '', ' '].sample }

        it 'returns a failure' do
          result = described_class.call(email:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_email)
          expect(result.data.keys).to contain_exactly(:invalid_email)
        end

        it 'exposes invalid_email' do
          result = described_class.call(email:)

          expect(result[:invalid_email]).to be(true)
        end
      end

      context 'when the email is invalid' do
        let(:email) { ['foo', 'foo.com'].sample }

        it 'returns a failure' do
          result = described_class.call(email:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_email)
        end

        it 'exposes the validation errors' do
          result = described_class.call(email:)

          expect(result[:invalid_email]).to be(true)
        end
      end

      context 'when the user is not found' do
        let(:email) { ::Faker::Internet.email }

        it 'returns a failure result' do
          result = described_class.call(email:)

          expect(result).to be_a_failure
          expect(result.type).to be(:user_not_found)
          expect(result.data.keys).to contain_exactly(:user_not_found)
        end

        it 'exposes user_not_found' do
          result = described_class.call(email:)

          expect(result[:user_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when the user is found' do
        include ActiveJob::TestHelper

        let!(:user) { create(:user) }
        let(:email) { [user.email, " #{user.email.capitalize}"].sample }

        it 'returns a succesful result' do
          result = described_class.call(email:)

          expect(result).to be_a_success
          expect(result.type).to be(:instructions_delivered)
          expect(result.data.keys).to contain_exactly(:instructions_delivered)
        end

        it 'exposes instructions_delivered' do
          result = described_class.call(email:)

          expect(result[:instructions_delivered]).to be(true)
        end

        it 'changes the user reset_password_token' do
          expect {
            described_class.call(email:)
          }.to change { user.reload.reset_password_token }
        end

        it 'sends an email in background' do
          expect {
            described_class.call(email:)
          }.to(
            have_enqueued_job(ActionMailer::MailDeliveryJob)
              .on_queue('default')
              .with('User::Mailer', 'reset_password', any_args)
          )
        end
      end
    end
  end
end

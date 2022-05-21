# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Authentication::ValidateEmailAndPassword, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the password is blank' do
        let(:email) { Faker::Internet.email }
        let(:password) { [nil, '', '  '].sample }

        it 'returns a failure result' do
          result = described_class.call(email:, password:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_email_or_password)

          expect(result.data.keys).to contain_exactly(:invalid_email_or_password)
        end

        it 'exposes invalid_email_or_password' do
          result = described_class.call(email:, password:)

          expect(result[:invalid_email_or_password]).to be(true)
        end
      end

      context 'when the email is blank' do
        let(:email) { [nil, '', '  '].sample }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }

        it 'returns a failure result' do
          result = described_class.call(email:, password:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_email_or_password)

          expect(result.data.keys).to contain_exactly(:invalid_email_or_password)
        end

        it 'exposes invalid_email_or_password' do
          result = described_class.call(email:, password:)

          expect(result[:invalid_email_or_password]).to be(true)
        end
      end

      context 'when the email is invalid' do
        let(:email) { ['foo', 'foo.com'].sample }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }

        it 'returns a failure result' do
          result = described_class.call(email:, password:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_email_or_password)

          expect(result.data.keys).to contain_exactly(:invalid_email_or_password)
        end

        it 'exposes invalid_email_or_password' do
          result = described_class.call(email:, password:)

          expect(result[:invalid_email_or_password]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when the email and password are valid' do
        let(:email) { Faker::Internet.email }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }

        it 'returns a successful result' do
          result = described_class.call(email:, password:)

          expect(result).to be_a_success
          expect(result.type).to be(:valid_email_and_password)
          expect(result.data.keys).to contain_exactly(:valid_email_and_password)
        end

        it 'exposes valid_email_and_password' do
          result = described_class.call(email:, password:)

          expect(result[:valid_email_and_password]).to be(true)
        end
      end
    end
  end
end

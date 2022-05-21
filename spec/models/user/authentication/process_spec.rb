# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Authentication::Process, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the user is not found' do
        let(:email) { Faker::Internet.email }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }

        it 'returns a failure result' do
          result = described_class.call(email:, password:)

          expect(result).to be_a_failure
          expect(result.type).to be(:user_not_found)
          expect(result.data.keys).to contain_exactly(:user_not_found)
        end

        it 'exposes user_not_found' do
          result = described_class.call(email:, password:)

          expect(result[:user_not_found]).to be(true)
        end
      end

      context 'when the user is found and the password is invalid' do
        let!(:user) { create(:user) }

        let(:email) { user.email }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }

        it 'returns a failure result' do
          result = described_class.call(email:, password:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_password)
          expect(result.data.keys).to contain_exactly(:invalid_password)
        end

        it 'exposes invalid_password' do
          result = described_class.call(email:, password:)

          expect(result[:invalid_password]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when the user is found and the password is valid' do
        let!(:user) { create(:user) }

        let(:email) { [user.email, " #{user.email.capitalize}"].sample }
        let(:password) { '123456' }

        it 'returns a succesful result' do
          result = described_class.call(email:, password:)

          expect(result).to be_a_success
          expect(result.type).to be(:user_found)
          expect(result.data.keys).to contain_exactly(:user)
        end

        it 'exposes user' do
          result = described_class.call(email:, password:)

          expect(result[:user]).to be == user
        end
      end
    end
  end
end

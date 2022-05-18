# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::ValidateResetPasswordToken, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the token is invalid' do
        let(:token) { 'must-be-a-UUID' }

        it 'returns a failure' do
          result = described_class.call(token:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_token)
          expect(result.data.keys).to contain_exactly(:invalid_token)
        end

        it 'exposes invalid_token' do
          result = described_class.call(token:)

          expect(result[:invalid_token]).to be(true)
        end
      end

      context 'when the user is not found' do
        let(:token) { ::SecureRandom.uuid }

        it 'returns a failure' do
          result = described_class.call(token:)

          expect(result).to be_a_failure
          expect(result.type).to be(:user_not_found)
          expect(result.data.keys).to contain_exactly(:user_not_found)
        end

        it 'exposes user_not_found' do
          result = described_class.call(token:)

          expect(result[:user_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      let(:token) { ::SecureRandom.uuid }

      before do
        create(:user, reset_password_token: token)
      end

      it 'returns a successful result' do
        result = described_class.call(token:)

        expect(result).to be_a_success
        expect(result.type).to be(:valid_token)
        expect(result.data.keys).to contain_exactly(:valid_token)
      end

      it 'exposes valid_token' do
        result = described_class.call(token:)

        expect(result[:valid_token]).to be(true)
      end
    end
  end
end

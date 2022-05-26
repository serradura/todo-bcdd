# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Authenticate::ByAPIToken, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the token is blank' do
        let(:token) { [nil, '', ' '].sample }

        it 'returns a failure' do
          result = described_class.call(token:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_token)
          expect(result.data.keys).to contain_exactly(:invalid_token)
        end

        it 'exposes the validation errors' do
          result = described_class.call(token:)

          expect(result[:invalid_token]).to be(true)
        end
      end

      context 'when the token is invalid' do
        let(:token) { ['foo', 'foo.com'].sample }

        it 'returns a failure' do
          result = described_class.call(token:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_token)
          expect(result.data.keys).to contain_exactly(:invalid_token)
        end

        it 'exposes the validation errors' do
          result = described_class.call(token:)

          expect(result[:invalid_token]).to be(true)
        end
      end

      context 'when the user is not found' do
        let(:token) { Faker::Alphanumeric.alphanumeric(number: 36) }

        it 'returns a failure result' do
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
    end

    describe 'success' do
      context 'when the user is found' do
        let!(:user) { create(:user) }
        let!(:token) { user.api_token }

        it 'returns a succesful result' do
          result = described_class.call(token:)

          expect(result).to be_a_success
          expect(result.type).to be(:user_found)
          expect(result.data.keys).to contain_exactly(:user)
        end

        it 'exposes user_found' do
          result = described_class.call(token:)

          expect(result[:user]).to be == user
        end
      end
    end
  end
end

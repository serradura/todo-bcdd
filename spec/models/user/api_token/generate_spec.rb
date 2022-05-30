# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::APIToken::Generate, type: :use_case do
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

        it 'exposes the invalid_token' do
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

        it 'exposes the invalid_token' do
          result = described_class.call(token:)

          expect(result[:invalid_token]).to be(true)
        end
      end

      context 'when the user is not found' do
        let(:token) { Faker::Alphanumeric.alphanumeric(number: 36) }

        it 'returns a failure result' do
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
      context 'when the user is found' do
        let!(:created_at) { 10.seconds.ago }
        let!(:user) { create(:user, created_at:, updated_at: created_at) }
        let!(:token) { user.api_token }

        it 'returns a succesful result' do
          result = described_class.call(token:)

          expect(result).to be_a_success
          expect(result.type).to be(:api_token_updated)
          expect(result.data.keys).to contain_exactly(:api_token_updated)
        end

        it 'exposes instructions_delivered' do
          result = described_class.call(token:)

          expect(result[:api_token_updated]).to be(true)
        end

        it 'changes the user api_token' do
          expect { described_class.call(token:) }
            .to change { user.reload.api_token }

          expect(user.api_token.size).to be == 36
        end

        it 'changes the user updated_at' do
          expect { described_class.call(token:) }
            .to change { user.reload.updated_at }

          expect(user.created_at).to be <= user.updated_at
        end
      end
    end
  end
end

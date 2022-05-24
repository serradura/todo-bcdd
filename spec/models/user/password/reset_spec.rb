# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Password::Reset, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the token is invalid' do
        let(:token) { 'must-be-a-UUID' }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }
        let(:password_confirmation) { password }

        it 'returns a failure' do
          result = described_class.call(token:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_token)
          expect(result.data.keys).to contain_exactly(:invalid_token)
        end

        it 'exposes invalid_token' do
          result = described_class.call(token:, password:, password_confirmation:)

          expect(result[:invalid_token]).to be(true)
        end
      end

      context 'when passwords are blank' do
        let(:token) { ::SecureRandom.uuid }
        let(:password) { [nil, '', ' '].sample }
        let(:password_confirmation) { [nil, '', ' '].sample }

        it 'returns a failure' do
          result = described_class.call(token:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_password)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes errors' do
          result = described_class.call(token:, password:, password_confirmation:)

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
        let(:token) { ::SecureRandom.uuid }
        let(:password) { Faker::Alphanumeric.alpha(number: 5) }
        let(:password_confirmation) { Faker::Alphanumeric.alpha(number: 6) }

        it 'returns a failure' do
          result = described_class.call(token:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_password)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes errors' do
          result = described_class.call(token:, password:, password_confirmation:)

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
        let(:token) { ::SecureRandom.uuid }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }
        let(:password_confirmation) { password.reverse }

        it 'returns a failure' do
          result = described_class.call(token:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_password)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes errors' do
          result = described_class.call(token:, password:, password_confirmation:)

          expect(result[:errors]).to have_attributes(
            itself: be_a(Hash),
            keys: contain_exactly(:password_confirmation)
          )

          expect(result[:errors])
            .to match(hash_including(password_confirmation: "doesn't match password"))
        end
      end

      context 'when the user is not found' do
        let(:token) { ::SecureRandom.uuid }
        let(:password) { Faker::Alphanumeric.alpha(number: 6) }
        let(:password_confirmation) { password }

        it 'returns a failure' do
          result = described_class.call(token:, password:, password_confirmation:)

          expect(result).to be_a_failure
          expect(result.type).to be(:user_not_found)
          expect(result.data.keys).to contain_exactly(:user_not_found)
        end

        it 'exposes user_not_found' do
          result = described_class.call(token:, password:, password_confirmation:)

          expect(result[:user_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      let!(:user) { create(:user, reset_password_token: token) }
      let!(:token) { ::SecureRandom.uuid }
      let!(:password) { Faker::Alphanumeric.alpha(number: 6) }
      let!(:password_confirmation) { password }

      it 'returns a successful result' do
        result = described_class.call(token:, password:, password_confirmation:)

        expect(result).to be_a_success
        expect(result.type).to be(:user_password_changed)
        expect(result.data.keys).to contain_exactly(:user)
      end

      it 'exposes user' do
        result = described_class.call(token:, password:, password_confirmation:)

        expect(result[:user]).to be == user
      end

      it 'changes the user encrypted_password' do
        expect {
          described_class.call(token:, password:, password_confirmation:)
        }.to change { user.reload.encrypted_password }

        expect(::BCrypt::Password.new(user.encrypted_password)).to be == password
      end
    end
  end
end

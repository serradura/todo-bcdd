# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Find, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the id is blank' do
        let(:id) { [nil, '', ' '].sample }

        it 'returns a failure' do
          result = described_class.call(id:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(id:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:id)
        end
      end

      context 'when the id is not numeric' do
        let(:id) { Faker::Alphanumeric.alpha(number: 1) }

        it 'returns a failure' do
          result = described_class.call(id:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(id:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:id)
        end
      end

      context 'when the id is not an integer' do
        let(:id) { [1.0, '1.0'].sample }

        it 'returns a failure' do
          result = described_class.call(id:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(id:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:id)
        end
      end

      context 'when a user is not found' do
        it 'returns a failure result' do
          result = described_class.call(id: 1)

          expect(result).to be_a_failure
          expect(result.type).to be(:user_not_found)
          expect(result.data.keys).to contain_exactly(:user_not_found)
        end

        it 'exposes user_not_found' do
          result = described_class.call(id: '1')

          expect(result[:user_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when a user is found' do
        let!(:user) { create(:user) }

        it 'returns a successful result' do
          result = described_class.call(id: user.id)

          expect(result).to be_a_success
          expect(result.type).to be(:user_found)
          expect(result.data.keys).to contain_exactly(:user)
        end

        it 'exposes the user' do
          result = described_class.call(id: user.id)

          expect(result[:user]).to be == user
        end
      end
    end
  end
end

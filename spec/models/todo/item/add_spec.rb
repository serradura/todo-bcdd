# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::Item::Add, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the description is blank' do
        let(:user_id) { rand(1..100) }
        let(:description) { [nil, '', ' '].sample }

        it 'returns a failure' do
          result = described_class.call(user_id:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_description)
          expect(result.data.keys).to contain_exactly(:error)
        end

        it 'exposes the error' do
          result = described_class.call(user_id:, description:)

          expect(result[:error]).to be == "can't be blank"
        end
      end

      context 'when the user_id is blank' do
        let(:user_id) { [nil, '', ' '].sample }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure' do
          result = described_class.call(user_id:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_scope)
          expect(result.data.keys).to contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          result = described_class.call(user_id:, description:)

          expect(result[:invalid_scope]).to be(true)
        end
      end

      context "when the user_id isn't numeric" do
        let(:user_id) { Faker::Alphanumeric.alpha(number: 1) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure' do
          result = described_class.call(user_id:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_scope)
          expect(result.data.keys).to contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          result = described_class.call(user_id:, description:)

          expect(result[:invalid_scope]).to be(true)
        end
      end

      context "when the user_id isn't integer" do
        let(:user_id) { [1.0, '1.0'].sample }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure' do
          result = described_class.call(user_id:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_scope)
          expect(result.data.keys).to contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          result = described_class.call(user_id:, description:)

          expect(result[:invalid_scope]).to be(true)
        end
      end

      context 'when the user is not found' do
        let(:user_id) { rand(100..200) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure result' do
          result = described_class.call(user_id: user_id.to_s, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:user_not_found)
          expect(result.data.keys).to contain_exactly(:user_not_found)
        end

        it 'exposes user_not_found' do
          result = described_class.call(user_id: user_id, description:)

          expect(result[:user_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when the user and description are valid' do
        let!(:user) { create(:user) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a successful result' do
          result = described_class.call(user_id: user.id, description:)

          expect(result).to be_a_success
          expect(result.type).to be(:todo_added)
          expect(result.data.keys).to contain_exactly(:todo)
        end

        it 'exposes todo' do
          result = described_class.call(user_id: user.id.to_s, description:)

          expect(result[:todo]).to have_attributes(
            itself: be_a(Todo::Item::Record),
            user_id: user.id,
            persisted?: true,
            description: description
          )
        end

        it 'creates a todo' do
          expect { described_class.call(user_id: user.id, description:) }
            .to change { Todo::Item::Record.where(user: user.id).count }.by(1)

          expect(::Todo::Item::Record.count).to be == 1
        end
      end
    end
  end
end

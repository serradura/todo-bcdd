# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::List::AddItem, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the description is blank' do
        let(:scope) { Todo::List::Scope.new(owner_id: rand(1..100)) }
        let(:description) { [nil, '', ' '].sample }

        it 'returns a failure' do
          result = described_class.call(scope:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_description)
          expect(result.data.keys).to contain_exactly(:error)
        end

        it 'exposes the error' do
          result = described_class.call(scope:, description:)

          expect(result[:error]).to be == "can't be blank"
        end
      end

      context 'when the scope attribute has the wrong kind' do
        let(:scope) { nil }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure' do
          result = described_class.call(scope:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(scope:, description:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:scope)
        end
      end

      context 'when the scope is invalid' do
        let(:scope) { ::Todo::List::Scope.new({}) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure' do
          result = described_class.call(scope:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_scope)
          expect(result.data.keys).to contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          result = described_class.call(scope:, description:)

          expect(result[:invalid_scope]).to be(true)
        end
      end

      context 'when the user is not found' do
        let(:scope) { ::Todo::List::Scope.new(owner_id: rand(1..100)) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure result' do
          result = described_class.call(scope:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:user_not_found)
          expect(result.data.keys).to contain_exactly(:user_not_found)
        end

        it 'exposes user_not_found' do
          result = described_class.call(scope:, description:)

          expect(result[:user_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when the user and description are valid' do
        let!(:user) { create(:user) }
        let(:scope) { Todo::List::Scope.new(owner_id: user.id) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a successful result' do
          result = described_class.call(scope:, description:)

          expect(result).to be_a_success
          expect(result.type).to be(:todo_added)
          expect(result.data.keys).to contain_exactly(:todo)
        end

        it 'exposes todo' do
          result = described_class.call(scope:, description:)

          item = result[:todo]

          expect(item).to match(Todo::Item)

          todo = ::Todo::Item::Record.find(item.id)

          expect(todo.id).to be == item.id
          expect(todo.user_id).to be == scope.owner_id.value
        end

        it 'creates a todo' do
          expect { described_class.call(scope:, description:) }
            .to change { Todo::Item::Record.where(user: user.id).count }.by(1)

          expect(::Todo::Item::Record.count).to be == 1
        end
      end
    end
  end
end

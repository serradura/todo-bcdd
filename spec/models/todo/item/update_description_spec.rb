# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::Item::UpdateDescription, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the description is blank' do
        let(:scope) { Todo::Item::Scope.new(id: rand(1..100), owner_id: rand(1..100)) }
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
        let(:scope) { ::Todo::Item::Scope.new({}) }
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

      context 'when a todo is not found' do
        let(:users) { create_list(:user, 2) }
        let(:todo) { create(:todo_item, user: users.first) }
        let(:scope) { Todo::Item::Scope.new(owner_id: users.last.id, id: todo.id) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure result' do
          result = described_class.call(scope:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:todo_not_found)
          expect(result.data.keys).to contain_exactly(:todo_not_found)
        end

        it 'exposes todo_not_found' do
          result = described_class.call(scope:, description:)

          expect(result[:todo_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when a todo is found' do
        let!(:user) { create(:user) }
        let!(:todo) { create(:todo_item, user: user, created_at: 10.seconds.ago) }
        let(:scope) { Todo::Item::Scope.new(owner_id: user.id, id: todo.id) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a successful result' do
          result = described_class.call(scope:, description:)

          expect(result).to be_a_success
          expect(result.type).to be(:todo_description_updated)
          expect(result.data.keys).to contain_exactly(:todo_description_updated)
        end

        it 'exposes todo_description_updated' do
          result = described_class.call(scope:, description:)

          expect(result[:todo_description_updated]).to be(true)
        end

        it 'changes the todo description' do
          expect { described_class.call(scope:, description:) }
            .to change { todo.reload.description }

          expect(todo.description).to be == description
        end
      end
    end
  end
end

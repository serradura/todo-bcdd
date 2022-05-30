# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::Item::Delete, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the scope attribute has the wrong kind' do
        let(:scope) { nil }

        it 'returns a failure' do
          result = described_class.call(scope:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(scope:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:scope)
        end
      end

      context 'when the scope is invalid' do
        let(:scope) { ::Todo::Item::Scope.new({}) }

        it 'returns a failure' do
          result = described_class.call(scope:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_scope)
          expect(result.data.keys).to contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          result = described_class.call(scope:)

          expect(result[:invalid_scope]).to be(true)
        end
      end

      context 'when a todo is not found' do
        let(:users) { create_list(:user, 2) }
        let(:todo) { create(:todo_item, user: users.first) }
        let(:scope) { Todo::Item::Scope.new(owner_id: users.last.id, id: todo.id) }

        it 'returns a failure result' do
          result = described_class.call(scope:)

          expect(result).to be_a_failure
          expect(result.type).to be(:todo_not_found)
          expect(result.data.keys).to contain_exactly(:todo_not_found)
        end

        it 'exposes todo_not_found' do
          result = described_class.call(scope:)

          expect(result[:todo_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when a todo is found' do
        let!(:user) { create(:user) }
        let!(:todo) { create(:todo_item, user: user) }
        let!(:scope) { Todo::Item::Scope.new(owner_id: user.id, id: todo.id) }

        before do
          other_user = create(:user)

          create(:todo_item, user: other_user)
        end

        it 'returns a successful result' do
          result = described_class.call(scope:)

          expect(result).to be_a_success
          expect(result.type).to be(:todo_deleted)
          expect(result.data.keys).to contain_exactly(:todo_deleted)
        end

        it 'exposes todo_deleted' do
          result = described_class.call(scope:)

          expect(result[:todo_deleted]).to be(true)
        end

        it 'deletes the todo from the database' do
          expect { described_class.call(scope:) }
            .to change { Todo::Item::Record.where(user_id: user.id).count }
            .from(1).to(0)

          expect(Todo::Item::Record.last.user_id).not_to be == user.id
        end
      end
    end
  end
end

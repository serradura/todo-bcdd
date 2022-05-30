# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::List::FilterItems, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the status is invalid' do
        let(:scope) { Todo::List::Scope.new(owner_id: rand(1..100)) }
        let(:status) { ['foo', 'bar', :foo, :bar].sample }

        it 'returns a failure' do
          result = described_class.call(scope:, status:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_status)
          expect(result.data.keys).to contain_exactly(:error)
        end

        it 'exposes the error' do
          result = described_class.call(scope:, status:)

          expect(result[:error]).to be == 'is invalid'
        end
      end

      context 'when the scope attribute has the wrong kind' do
        let(:scope) { nil }
        let(:status) { [:completed, :uncompleted, 'completed', 'uncompleted'].sample }

        it 'returns a failure' do
          result = described_class.call(scope:, status:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(scope:, status:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:scope)
        end
      end

      context 'when the scope is invalid' do
        let(:scope) { ::Todo::List::Scope.new({}) }
        let(:status) { [:completed, :uncompleted, 'completed', 'uncompleted'].sample }

        it 'returns a failure' do
          result = described_class.call(scope:, status:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_scope)
          expect(result.data.keys).to contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          result = described_class.call(scope:, status:)

          expect(result[:invalid_scope]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when the user is not found' do
        let(:scope) { Todo::List::Scope.new(owner_id: rand(1..100)) }
        let(:status) { [:completed, :uncompleted].sample }

        it 'returns a successful result' do
          result = described_class.call(scope:, status:)

          expect(result).to be_a_success
          expect(result.type).to be(:todos_filtered)
          expect(result.data.keys).to contain_exactly(:todos)
        end

        it 'exposes todos' do
          result = described_class.call(scope:, status:)

          expect(result[:todos]).to have_attributes(
            itself: ActiveRecord::Relation,
            klass: Todo::Item::Record,
            empty?: true
          )
        end
      end

      context 'when user is found and the status is completed' do
        let!(:user) { create(:user) }
        let!(:completed_todo) { create(:todo_item, :completed, user: user) }

        let(:status) { :completed }
        let(:scope) { Todo::List::Scope.new(owner_id: user.id) }

        before do
          create(:todo_item, user: user)
          create(:todo_item, :completed, user: create(:user))
        end

        it 'returns a successful result' do
          result = described_class.call(scope:, status:)

          expect(result).to be_a_success
          expect(result.type).to be(:todos_filtered)
          expect(result.data.keys).to contain_exactly(:todos)
        end

        it 'exposes todos' do
          result = described_class.call(scope:, status:)

          expect(result[:todos]).to have_attributes(
            itself: ActiveRecord::Relation,
            klass: Todo::Item::Record,
            size: 1
          )

          expect(result[:todos]).to include(completed_todo)
        end
      end

      context 'when user is found and the status is uncompleted' do
        let!(:user) { create(:user) }
        let!(:uncompleted_todo) { create(:todo_item, user: user) }

        let(:status) { :uncompleted }
        let(:scope) { Todo::List::Scope.new(owner_id: user.id) }

        before do
          create(:todo_item, :completed, user: user)
          create(:todo_item, user: create(:user))
        end

        it 'returns a successful result' do
          result = described_class.call(scope:, status:)

          expect(result).to be_a_success
          expect(result.type).to be(:todos_filtered)
          expect(result.data.keys).to contain_exactly(:todos)
        end

        it 'exposes todos' do
          result = described_class.call(scope:, status:)

          expect(result[:todos]).to have_attributes(
            itself: ActiveRecord::Relation,
            klass: Todo::Item::Record,
            size: 1
          )

          expect(result[:todos]).to include(uncompleted_todo)
        end
      end
    end
  end
end

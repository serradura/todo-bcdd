# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::Item::UpdateDescription, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the description is blank' do
        let(:id) { rand(1..100) }
        let(:user_id) { rand(1..100) }
        let(:description) { [nil, '', ' '].sample }

        it 'returns a failure' do
          result = described_class.call(user_id:, id:, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_description)
          expect(result.data.keys).to contain_exactly(:error)
        end

        it 'exposes the error' do
          result = described_class.call(user_id:, id:, description:)

          expect(result[:error]).to be == "can't be blank"
        end
      end

      context 'when the ids are blank' do
        let(:id) { [nil, '', ' '].sample }
        let(:user_id) { [nil, '', ' '].sample }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure' do
          results = [
            described_class.call(id:, user_id: 1),
            described_class.call(id: 1, user_id:)
          ]

          expect(results).to all be_a_failure
          expect(results.map(&:type)).to all be(:invalid_scope)
          expect(results.map(&:data).map(&:keys)).to all contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          results = [
            described_class.call(id:, user_id: 1),
            described_class.call(id: 1, user_id:)
          ]

          expect(results.pluck(:invalid_scope)).to all be(true)
        end
      end

      context "when the ids aren't numerics" do
        let(:id) { Faker::Alphanumeric.alpha(number: 1) }
        let(:user_id) { Faker::Alphanumeric.alpha(number: 1) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure' do
          results = [
            described_class.call(id:, user_id: 1),
            described_class.call(id: 1, user_id:)
          ]

          expect(results).to all be_a_failure
          expect(results.map(&:type)).to all be(:invalid_scope)
          expect(results.map(&:data).map(&:keys)).to all contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          results = [
            described_class.call(id:, user_id: 1),
            described_class.call(id: 1, user_id:)
          ]

          expect(results.pluck(:invalid_scope)).to all be(true)
        end
      end

      context "when the ids aren't integers" do
        let(:id) { [1.0, '1.0'].sample }
        let(:user_id) { Faker::Alphanumeric.alpha(number: 1) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure' do
          results = [
            described_class.call(id:, user_id: 1),
            described_class.call(id: 1, user_id:)
          ]

          expect(results).to all be_a_failure
          expect(results.map(&:type)).to all be(:invalid_scope)
          expect(results.map(&:data).map(&:keys)).to all contain_exactly(:invalid_scope)
        end

        it 'exposes the invalid_scope' do
          results = [
            described_class.call(id:, user_id: 1),
            described_class.call(id: 1, user_id:)
          ]

          expect(results.pluck(:invalid_scope)).to all be(true)
        end
      end

      context 'when a todo is not found' do
        let!(:users) { create_list(:user, 2) }
        let!(:user) { users.last }
        let!(:todo) { create(:todo_item, user: users.first) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a failure result' do
          result = described_class.call(id: todo.id, user_id: user.id.to_s, description:)

          expect(result).to be_a_failure
          expect(result.type).to be(:todo_not_found)
          expect(result.data.keys).to contain_exactly(:todo_not_found)
        end

        it 'exposes todo_not_found' do
          result = described_class.call(id: todo.id.to_s, user_id: user.id, description:)

          expect(result[:todo_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when a todo is found' do
        let!(:user) { create(:user) }
        let!(:todo) { create(:todo_item, user: user, created_at: 10.seconds.ago) }
        let(:description) { Faker::Lorem.sentence(word_count: 3) }

        it 'returns a successful result' do
          result = described_class.call(id: todo.id.to_s, user_id: user.id, description:)

          expect(result).to be_a_success
          expect(result.type).to be(:todo_description_updated)
          expect(result.data.keys).to contain_exactly(:todo_description_updated)
        end

        it 'exposes todo_description_updated' do
          result = described_class.call(id: todo.id, user_id: user.id.to_s, description:)

          expect(result[:todo_description_updated]).to be(true)
        end

        it 'changes the todo description' do
          expect { described_class.call(id: todo.id, user_id: user.id.to_s, description:) }
            .to change { todo.reload.description }

          expect(todo.description).to be == description
        end
      end
    end
  end
end

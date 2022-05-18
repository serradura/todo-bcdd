# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::Complete, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the ids are blank' do
        let(:id) { [nil, '', ' '].sample }
        let(:user_id) { [nil, '', ' '].sample }

        it 'returns a failure' do
          result = described_class.call(id:, user_id:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(id:, user_id:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:id, :user_id)
        end
      end

      context "when the ids aren't numerics" do
        let(:id) { Faker::Alphanumeric.alpha(number: 1) }
        let(:user_id) { Faker::Alphanumeric.alpha(number: 1) }

        it 'returns a failure' do
          result = described_class.call(id:, user_id:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(id:, user_id:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:id, :user_id)
        end
      end

      context "when the ids aren't integers" do
        let(:id) { [1.0, '1.0'].sample }
        let(:user_id) { [1.0, '1.0'].sample }

        it 'returns a failure' do
          result = described_class.call(id:, user_id:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(id:, user_id:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:id)
        end
      end

      context 'when a todo is not found' do
        let!(:users) { create_list(:user, 2) }
        let!(:user) { users.last }
        let!(:todo) { create(:todo, user: users.first) }

        it 'returns a failure result' do
          result = described_class.call(id: todo.id, user_id: user.id.to_s)

          expect(result).to be_a_failure
          expect(result.type).to be(:todo_not_found)
          expect(result.data.keys).to contain_exactly(:todo_not_found)
        end

        it 'exposes todo_not_found' do
          result = described_class.call(id: todo.id.to_s, user_id: user.id)

          expect(result[:todo_not_found]).to be(true)
        end
      end
    end

    describe 'success' do
      context 'when a todo is found' do
        let!(:user) { create(:user) }
        let!(:todo) { create(:todo, user: user, created_at: 10.seconds.ago) }

        it 'returns a successful result' do
          result = described_class.call(id: todo.id.to_s, user_id: user.id)

          expect(result).to be_a_success
          expect(result.type).to be(:todo_completed)
          expect(result.data.keys).to contain_exactly(:todo_completed)
        end

        it 'exposes todo_completed' do
          result = described_class.call(id: todo.id, user_id: user.id.to_s)

          expect(result[:todo_completed]).to be(true)
        end

        it 'changes the todo completed_at' do
          expect { described_class.call(id: todo.id, user_id: user.id.to_s) }
            .to change { todo.reload.completed_at }
            .from(nil).to be_a(ActiveSupport::TimeWithZone)
        end
      end
    end
  end
end

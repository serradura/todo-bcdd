# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::List::FilterItems, type: :use_case do
  describe '.call' do
    describe 'failures' do
      context 'when the status is invalid' do
        let(:user_id) { [1, 2, 3].sample }
        let(:status) { ['completed', 'uncompleted', :foo, :bar].sample }

        it 'returns a failure' do
          result = described_class.call(user_id:, status:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(user_id:, status:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:status)
        end
      end

      context 'when the user_id is blank' do
        let(:user_id) { [nil, '', ' '].sample }
        let(:status) { [:completed, :uncompleted].sample }

        it 'returns a failure' do
          result = described_class.call(user_id:, status:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(user_id:, status:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:user_id)
        end
      end

      context "when the user_id isn't numeric" do
        let(:user_id) { Faker::Alphanumeric.alpha(number: 1) }
        let(:status) { [:completed, :uncompleted].sample }

        it 'returns a failure' do
          result = described_class.call(user_id:, status:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(user_id:, status:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:user_id)
        end
      end

      context "when the user_id isn't integer" do
        let(:user_id) { [1.0, '1.0'].sample }
        let(:status) { [:completed, :uncompleted].sample }

        it 'returns a failure' do
          result = described_class.call(user_id:, status:)

          expect(result).to be_a_failure
          expect(result.type).to be(:invalid_attributes)
          expect(result.data.keys).to contain_exactly(:errors)
        end

        it 'exposes the validation errors' do
          result = described_class.call(user_id:, status:)

          expect(result[:errors]).to be_a(::ActiveModel::Errors).and include(:user_id)
        end
      end
    end

    describe 'success' do
      context 'when the user is not found' do
        let(:user_id) { rand(100..200) }
        let(:status) { [:completed, :uncompleted].sample }

        it 'returns a successful result' do
          result = described_class.call(user_id: user_id.to_s, status:)

          expect(result).to be_a_success
          expect(result.type).to be(:todos_filtered)
          expect(result.data.keys).to contain_exactly(:todos)
        end

        it 'exposes todos' do
          result = described_class.call(user_id: user_id.to_s, status:)

          expect(result[:todos]).to have_attributes(
            itself: ActiveRecord::Relation,
            klass: Todo,
            empty?: true
          )
        end
      end

      context 'when user is found and the status is completed' do
        let(:status) { :completed }
        let!(:user) { create(:user) }
        let!(:completed_todo) { create(:todo, :completed, user: user) }

        before do
          create(:todo, user: user)
          create(:todo, :completed, user: create(:user))
        end

        it 'returns a successful result' do
          result = described_class.call(user_id: user.id.to_s, status:)

          expect(result).to be_a_success
          expect(result.type).to be(:todos_filtered)
          expect(result.data.keys).to contain_exactly(:todos)
        end

        it 'exposes todos' do
          result = described_class.call(user_id: user.id.to_s, status:)

          expect(result[:todos]).to have_attributes(
            itself: ActiveRecord::Relation,
            klass: Todo,
            size: 1
          )

          expect(result[:todos]).to include(completed_todo)
        end
      end

      context 'when user is found and the status is uncompleted' do
        let(:status) { :uncompleted }
        let!(:user) { create(:user) }
        let!(:uncompleted_todo) { create(:todo, user: user) }

        before do
          create(:todo, :completed, user: user)
          create(:todo, user: create(:user))
        end

        it 'returns a successful result' do
          result = described_class.call(user_id: user.id.to_s, status:)

          expect(result).to be_a_success
          expect(result.type).to be(:todos_filtered)
          expect(result.data.keys).to contain_exactly(:todos)
        end

        it 'exposes todos' do
          result = described_class.call(user_id: user.id.to_s, status:)

          expect(result[:todos]).to have_attributes(
            itself: ActiveRecord::Relation,
            klass: Todo,
            size: 1
          )

          expect(result[:todos]).to include(uncompleted_todo)
        end
      end
    end
  end
end

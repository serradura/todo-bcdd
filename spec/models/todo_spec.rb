# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe 'database indexes' do
    it { is_expected.to have_db_index([:user_id, :id]) }
  end

  describe 'associations' do
    describe 'belongs_to' do
      it { is_expected.to belong_to(:user) }
    end
  end

  describe 'validations' do
    describe 'description' do
      it { is_expected.to validate_presence_of(:description) }
    end
  end

  describe 'scopes' do
    describe '.completed' do
      let!(:user) { create(:user) }
      let!(:completed) { create(:todo, :completed, user:) }

      before { create(:todo, user:) }

      it 'filters completed records' do
        todos = described_class.completed.to_a

        expect(todos.size).to be == 1
        expect(todos).to include(completed)
      end
    end

    describe '.uncompleted' do
      let!(:user) { create(:user) }
      let!(:uncompleted) { create(:todo, user:) }

      before { create(:todo, :completed, user:) }

      it 'filters uncompleted records' do
        todos = described_class.uncompleted.to_a

        expect(todos.size).to be == 1
        expect(todos).to include(uncompleted)
      end
    end
  end

  describe '#status' do
    context 'when it is completed' do
      subject { build(:todo, :completed).status }

      it { is_expected.to be == :completed }
    end

    context 'when it is uncompleted' do
      subject { build(:todo).status }

      it { is_expected.to be == :uncompleted }
    end
  end

  describe '#completed?' do
    context 'when there is a completed_at' do
      subject { described_class.new(completed_at: Time.current) }

      it { is_expected.to be_completed }
    end

    context 'when there is no completed_at' do
      subject { described_class.new(completed_at: nil) }

      it { is_expected.not_to be_completed }
    end
  end

  describe '#uncompleted?' do
    context 'when there is no completed_at' do
      subject { described_class.new(completed_at: nil) }

      it { is_expected.to be_uncompleted }
    end

    context 'when there is a completed_at' do
      subject { described_class.new(completed_at: Time.current) }

      it { is_expected.not_to be_uncompleted }
    end
  end
end

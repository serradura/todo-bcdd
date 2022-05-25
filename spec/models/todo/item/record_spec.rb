# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::Item::Record, type: :model do
  subject { build(:todo_item) }

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

  describe '#status' do
    context 'when it is completed' do
      subject { build(:todo_item, :completed).status }

      it { is_expected.to be == :completed }
    end

    context 'when it is uncompleted' do
      subject { build(:todo_item).status }

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

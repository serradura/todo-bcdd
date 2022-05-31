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
end

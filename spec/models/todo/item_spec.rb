# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::Item, type: :model do
  subject(:item) { described_class.new(id:, description:, completed_at:, created_at:, updated_at:) }

  let(:id) { nil }
  let(:description) { nil }
  let(:completed_at) { nil }
  let(:created_at) { nil }
  let(:updated_at) { nil }

  describe '.===' do
    it 'verifies if the given object is your instance' do
      expect(described_class === item).to be(true)

      expect(described_class === Object.new).to be(false)
    end
  end

  describe '#id' do
    let(:id) { 1 }

    it { expect(item.id).to be == id }
  end

  describe '#description' do
    let(:description) { 'Buy milk' }

    it { expect(item.description).to be == description }
  end

  describe '#completed_at' do
    let(:completed_at) { Time.current }

    it { expect(item.completed_at).to be == completed_at }
  end

  describe '#created_at' do
    let(:created_at) { Time.current }

    it { expect(item.created_at).to be == created_at }
  end

  describe '#updated_at' do
    let(:updated_at) { Time.current }

    it { expect(item.updated_at).to be == updated_at }
  end

  describe '#status' do
    context 'when there is a completed_at' do
      let(:completed_at) { Time.current }

      it { expect(item.status).to be == :completed }
    end

    context 'when there is no completed_at' do
      let(:completed_at) { nil }

      it { expect(item.status).to be == :uncompleted }
    end
  end

  describe '#completed?' do
    context 'when there is a completed_at' do
      let(:completed_at) { Time.current }

      it { expect(item).to be_completed }
    end

    context 'when there is no completed_at' do
      let(:completed_at) { nil }

      it { expect(item).not_to be_completed }
    end
  end

  describe '#uncompleted?' do
    context 'when there is no completed_at' do
      let(:completed_at) { nil }

      it { expect(item).to be_uncompleted }
    end

    context 'when there is a completed_at' do
      let(:completed_at) { Time.current }

      it { expect(item).not_to be_uncompleted }
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::Item::Scope, type: :use_case do
  describe '#invalid?' do
    context 'when the ids are blank' do
      let(:id) { [nil, '', ' '].sample }
      let(:owner_id) { [nil, '', ' '].sample }

      it do
        scopes = [
          described_class.new(id:, owner_id: 1),
          described_class.new(id: 1, owner_id:)
        ]

        expect(scopes).to all have_attributes(valid?: false, invalid?: true)
      end
    end

    context "when the ids aren't numerics" do
      let(:id) { Faker::Alphanumeric.alpha(number: 1) }
      let(:owner_id) { Faker::Alphanumeric.alpha(number: 1) }

      it do
        scopes = [
          described_class.new(id:, owner_id: 1),
          described_class.new(id: 1, owner_id:)
        ]

        expect(scopes).to all have_attributes(valid?: false, invalid?: true)
      end
    end

    context "when the ids aren't integers" do
      let(:id) { [1.0, '1.0'].sample }
      let(:owner_id) { [1.0, '1.0'].sample }

      it do
        scopes = [
          described_class.new(id:, owner_id: 1),
          described_class.new(id: 1, owner_id:)
        ]

        expect(scopes).to all have_attributes(valid?: false, invalid?: true)
      end
    end

    context "when the ids aren't positive integers" do
      let(:id) { [0, -1].sample }
      let(:owner_id) { [-1, 0].sample }

      it do
        scopes = [
          described_class.new(id:, owner_id: 1),
          described_class.new(id: 1, owner_id:)
        ]

        expect(scopes).to all have_attributes(valid?: false, invalid?: true)
      end
    end
  end

  describe '#valid?' do
    context 'when the ids are positive integers' do
      subject(:scope) { described_class.new(id: 2, owner_id: 1) }

      it do
        expect(scope).to have_attributes(
          :id       => have_attributes(itself: be_a(Kind::ID), value: 2),
          :owner_id => have_attributes(itself: be_a(Kind::ID), value: 1),
          :valid?   => true,
          :invalid? => false
        )
      end
    end

    context 'when the ids are strings with positive integers' do
      subject(:scope) { described_class.new(id: '1', owner_id: '2') }

      it do
        expect(scope).to have_attributes(
          :id       => have_attributes(itself: be_a(Kind::ID), value: 1),
          :owner_id => have_attributes(itself: be_a(Kind::ID), value: 2),
          :valid?   => true,
          :invalid? => false
        )
      end
    end
  end
end

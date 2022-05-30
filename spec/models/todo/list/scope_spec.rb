# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo::List::Scope, type: :use_case do
  subject(:scope) { described_class.new(owner_id:) }

  describe '#invalid?' do
    context 'when the owner_id is blank' do
      let(:owner_id) { [nil, '', ' '].sample }

      it { expect(scope).to have_attributes(valid?: false, invalid?: true) }
    end

    context "when the owner_id isn't numeric" do
      let(:owner_id) { Faker::Alphanumeric.alpha(number: 1) }

      it { expect(scope).to have_attributes(valid?: false, invalid?: true) }
    end

    context "when the ids aren't integers" do
      let(:owner_id) { [1.0, '1.0'].sample }

      it { expect(scope).to have_attributes(valid?: false, invalid?: true) }
    end

    context "when the ids isn't positive integers" do
      let(:owner_id) { [-1, 0].sample }

      it { expect(scope).to have_attributes(valid?: false, invalid?: true) }
    end
  end

  describe '#valid?' do
    context 'when the ids are positive integers' do
      let(:owner_id) { 1 }

      it do
        expect(scope).to have_attributes(
          :owner_id => have_attributes(itself: be_a(Kind::ID), value: 1),
          :valid?   => true,
          :invalid? => false
        )
      end
    end

    context 'when the ids are strings with positive integers' do
      let(:owner_id) { '2' }

      it do
        expect(scope).to have_attributes(
          :owner_id => have_attributes(itself: be_a(Kind::ID), value: 2),
          :valid?   => true,
          :invalid? => false
        )
      end
    end
  end
end

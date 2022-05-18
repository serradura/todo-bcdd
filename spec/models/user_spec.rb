# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    describe 'has_many' do
      it { is_expected.to have_many(:todos) }
    end
  end

  describe 'validations' do
    describe 'email' do
      subject { described_class.new(email: '', encrypted_password: '') }

      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_uniqueness_of(:email) }
      it { is_expected.to allow_value('bar@bar.com').for(:email) }
      it { is_expected.not_to allow_value('bar.com').for(:email) }
    end

    describe 'encrypted_password' do
      it { is_expected.to validate_presence_of(:encrypted_password) }
    end
  end
end

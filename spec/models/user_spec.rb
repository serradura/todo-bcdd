# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    describe 'has_many' do
      it { is_expected.to have_many(:todos).dependent(nil) }
    end
  end

  describe 'validations' do
    describe 'email' do
      subject { described_class.new(email: '', encrypted_password: '', api_token: '') }

      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_uniqueness_of(:email) }
      it { is_expected.to allow_value('bar@bar.com', 'bar@bar').for(:email) }
      it { is_expected.not_to allow_value('bar.com').for(:email) }
    end

    describe 'encrypted_password' do
      it { is_expected.to validate_presence_of(:encrypted_password) }
    end

    describe 'api_token' do
      it { is_expected.to validate_presence_of(:api_token) }
      it { is_expected.to validate_length_of(:api_token).is_equal_to(36) }
    end
  end
end

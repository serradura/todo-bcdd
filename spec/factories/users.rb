# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: '::User::Record' do
    # encrypted_password = 123456

    email { ::Faker::Internet.email }
    encrypted_password { '$2a$12$sJxZQPRJlZsPhbqZH4eZkun210qXckPOxe24UFjBpkfVYiJG3C6Be' }
    reset_password_token { nil }
    api_token { ::User::APIToken::Value.new.value }
  end
end

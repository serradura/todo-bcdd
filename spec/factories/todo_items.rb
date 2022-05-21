# frozen_string_literal: true

FactoryBot.define do
  factory :todo_item, class: '::Todo::Item::Record' do
    user { nil }
    description { ::Faker::Hacker.say_something_smart }
    completed_at { nil }

    trait :completed do
      completed_at { ::Time.current }
    end
  end
end

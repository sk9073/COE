FactoryBot.define do
  factory :list do
    sequence(:title) { |n| "Task #{n}" }
    description { "Desc" }
    status { "to_do" }
  end
end

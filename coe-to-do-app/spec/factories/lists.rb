# == Schema Information
#
# Table name: lists
#
#  id          :integer          not null, primary key
#  created_at  :datetime         not null
#  description :text             not null
#  status      :string           not null
#  title       :text             not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lists_on_title  (title) UNIQUE
#

FactoryBot.define do
  factory :list do
    sequence(:title) { |n| "Task #{n}" }
    description { "Desc" }
    status { "to_do" }
  end
end

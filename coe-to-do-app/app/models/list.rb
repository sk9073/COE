# == Schema Information
#
# Table name: lists
#
#  id          :integer          not null, primary key
#  title       :text             not null
#  description :text             not null
#  status      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lists_on_title  (title) UNIQUE
#

class List < ApplicationRecord
  validates :status, inclusion: { in: %w[to_do in_progress done blocked], message: "%{value} is not a valid status" }
  validates :title, uniqueness: true
end

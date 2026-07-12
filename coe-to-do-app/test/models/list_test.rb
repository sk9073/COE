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

require "test_helper"

class ListTest < ActiveSupport::TestCase
  test "status must belong to to-do, in-progress, or done" do
    valid_statuses = %w[to-do in-progress done]
    valid_statuses.each do |status|
      list = List.new(title: "Task #{status}", description: "Desc", status: status)
      assert list.valid?, "#{status} should be a valid status"
    end

    invalid_statuses = %w[todo in_progress completed archive]
    invalid_statuses.each do |status|
      list = List.new(title: "Task #{status}", description: "Desc", status: status)
      assert_not list.valid?, "#{status} should be invalid"
      assert_includes list.errors[:status], "#{status} is not a valid status"
    end
  end
end

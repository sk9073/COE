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

require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'creating a list:' do
    it 'creates a list' do
      list = build(:list)
      expect(list).to be_valid
    end
  end

  describe 'validations' do
    it 'validates that status belongs to to_do, in_progress, done, or blocked' do
      valid_statuses = %w[to_do in_progress done blocked]
      valid_statuses.each do |status|
        list = build(:list, status: status)
        expect(list).to be_valid
      end
    end

    it 'validates title is unique' do
      create(:list, title: "Task 1")
      list = build(:list, title: "Task 1")
      list.valid?
      expect(list.errors[:title]).to include("has already been taken")
    end

    it 'throws error for invalide status' do
      invalid_statuses = %w[todo completed archive]
      invalid_statuses.each do |status|
        list = build(:list, status: status)
        expect(list).not_to be_valid
        expect(list.errors[:status]).to include("#{status} is not a valid status")
      end
    end
  end
end

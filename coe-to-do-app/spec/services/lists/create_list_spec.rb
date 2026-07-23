require 'rails_helper'

RSpec.describe Lists::CreateList do
  let(:cache) { instance_double(Lists::Cache, invalidate_all: nil) }
  subject(:command) { described_class.new(cache: cache) }

  it 'persists a new list with the given attributes' do
    list = command.call(title: 'Learn OOP', description: 'Sandi', status: 'to_do')

    expect(list).to be_persisted
    expect(list).to have_attributes(title: 'Learn OOP', description: 'Sandi', status: 'to_do')
  end

  it 'invalidates the cached reads after creating' do
    expect(cache).to receive(:invalidate_all)
    command.call(title: 'Learn OOP', description: 'Sandi', status: 'to_do')
  end

  it 'raises RecordInvalid on a duplicate title without touching the cache' do
    create(:list, title: 'Taken')
    expect(cache).not_to receive(:invalidate_all)

    expect do
      command.call(title: 'Taken', description: 'x', status: 'to_do')
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end

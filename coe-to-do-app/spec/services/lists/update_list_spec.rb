require 'rails_helper'

RSpec.describe Lists::UpdateList do
  let(:cache) { instance_double(Lists::Cache, invalidate_all: nil) }
  subject(:command) { described_class.new(cache: cache) }

  it 'updates only the supplied attributes' do
    list = create(:list, title: 'Original', description: 'Desc', status: 'to_do')

    command.call(id: list.id, status: 'done')

    expect(list.reload).to have_attributes(title: 'Original', description: 'Desc', status: 'done')
  end

  it 'invalidates the cache when something changed' do
    list = create(:list, status: 'to_do')
    expect(cache).to receive(:invalidate_all)

    command.call(id: list.id, status: 'done')
  end

  it 'does not touch the DB or cache when no attributes are supplied' do
    list = create(:list, status: 'to_do')
    expect(cache).not_to receive(:invalidate_all)

    expect { command.call(id: list.id) }.not_to change { list.reload.updated_at }
  end

  it 'raises RecordNotFound for a missing id' do
    expect { command.call(id: -1, status: 'done') }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

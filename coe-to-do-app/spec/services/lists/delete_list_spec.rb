require 'rails_helper'

RSpec.describe Lists::DeleteList do
  let(:cache) { instance_double(Lists::Cache, invalidate_all: nil) }
  subject(:command) { described_class.new(cache: cache) }

  it 'destroys the list and returns it' do
    list = create(:list)

    result = command.call(id: list.id)

    expect(result.id).to eq(list.id)
    expect(List.exists?(list.id)).to be(false)
  end

  it 'invalidates the cache after destroying' do
    list = create(:list)
    expect(cache).to receive(:invalidate_all)

    command.call(id: list.id)
  end

  it 'raises RecordNotFound for a missing id' do
    expect { command.call(id: -1) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

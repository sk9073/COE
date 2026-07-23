require 'rails_helper'

RSpec.describe Lists::Cache do
  # A fake store so we assert the messages Cache sends to its collaborator
  # (Sandi's testing grid: verify outgoing commands at the nearest boundary)
  # without depending on a real cache backend.
  let(:store) { instance_double(ActiveSupport::Cache::Store) }
  subject(:cache) { described_class.new(store: store) }

  describe '#fetch' do
    it 'reads the "all" key when no status is given' do
      expect(store).to receive(:fetch).with('all_lists/all', expires_in: described_class::EXPIRES_IN)
      cache.fetch
    end

    it 'reads the status-scoped key when a status is given' do
      expect(store).to receive(:fetch).with('all_lists/done', expires_in: described_class::EXPIRES_IN)
      cache.fetch('done')
    end

    it 'treats a blank status as "all"' do
      expect(store).to receive(:fetch).with('all_lists/all', expires_in: described_class::EXPIRES_IN)
      cache.fetch('')
    end

    it 'yields the block to the store to compute a miss' do
      allow(store).to receive(:fetch).and_yield
      expect { |b| cache.fetch('done', &b) }.to yield_control
    end
  end

  describe '#invalidate_all' do
    it 'deletes the "all" key and one key per valid status' do
      expected_keys = [ 'all_lists/all' ] + ListStatus::ALL.map { |s| "all_lists/#{s}" }
      expected_keys.each do |key|
        expect(store).to receive(:delete).with(key)
      end

      cache.invalidate_all
    end
  end
end

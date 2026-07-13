require 'rails_helper'

RSpec.describe 'allLists query', type: :graphql do
  let(:query) do
    <<~GRAPHQL
      query {
        allLists {
          id
          title
          description
          status
        }
      }
    GRAPHQL
  end

  it 'returns an empty list when there are no lists' do
    result = execute_graphql(query)

    expect(result['errors']).to be_nil
    expect(result['data']['allLists']).to eq([])
  end

  it 'returns all lists with their attributes' do
    first = create(:list, title: 'Task 1', description: 'Desc 1', status: 'to_do')
    second = create(:list, title: 'Task 2', description: 'Desc 2', status: 'done')

    result = execute_graphql(query)

    expect(result['errors']).to be_nil
    expect(result['data']['allLists']).to contain_exactly(
      { 'id' => first.id.to_s, 'title' => 'Task 1', 'description' => 'Desc 1', 'status' => 'to_do' },
      { 'id' => second.id.to_s, 'title' => 'Task 2', 'description' => 'Desc 2', 'status' => 'done' },
    )
  end
end

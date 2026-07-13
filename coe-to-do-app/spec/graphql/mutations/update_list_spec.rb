require 'rails_helper'

RSpec.describe 'updateList mutation', type: :graphql do
  let(:query) do
    <<~GRAPHQL
      mutation($input: UpdateListInput!) {
        updateList(input: $input) {
          id
          title
          description
          status
        }
      }
    GRAPHQL
  end

  it 'updates only the provided attributes' do
    list = create(:list, title: 'Original', description: 'Original desc', status: 'to_do')

    result = execute_graphql(query, variables: {
      input: { id: list.id, status: 'done' }
    })

    expect(result['errors']).to be_nil
    expect(result['data']['updateList']).to eq(
      'id' => list.id.to_s, 'title' => 'Original', 'description' => 'Original desc', 'status' => 'done',
    )
    expect(list.reload.status).to eq('done')
  end

  it 'returns an error when updating to a title already taken by another list' do
    create(:list, title: 'Taken')
    list = create(:list, title: 'Original')

    result = execute_graphql(query, variables: {
      input: { id: list.id, title: 'Taken' }
    })

    # updateList is a non-null field, so a resolver error nils out the whole `data`.
    expect(result['data']).to be_nil
    expect(result['errors'].first['message']).to eq('Title has already been taken')
    expect(list.reload.title).to eq('Original')
  end

  it 'raises when the list does not exist' do
    # List.find raises ActiveRecord::RecordNotFound before the mutation's own
    # "List not found" GraphQL::ExecutionError branch is ever reached.
    expect {
      execute_graphql(query, variables: { input: { id: -1, status: 'done' } })
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

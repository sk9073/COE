require 'rails_helper'

RSpec.describe 'createList mutation', type: :graphql do
  let(:query) do
    <<~GRAPHQL
      mutation($input: CreateListInput!) {
        createList(input: $input) {
          id
          title
          description
          status
        }
      }
    GRAPHQL
  end

  it 'creates a list and returns it' do
    result = execute_graphql(query, variables: {
      input: { title: 'Learn GraphQL', description: 'Learn', status: 'to_do' }
    })

    expect(result['errors']).to be_nil
    payload = result['data']['createList']
    expect(payload).to include('title' => 'Learn GraphQL', 'description' => 'Learn', 'status' => 'to_do')
    expect(List.find(payload['id']).title).to eq('Learn GraphQL')
  end

  it 'returns an error when the title is already taken' do
    create(:list, title: 'Duplicate')

    result = execute_graphql(query, variables: {
      input: { title: 'Duplicate', description: 'Desc', status: 'to_do' }
    })

    # createList is a non-null field, so a resolver error nils out the whole `data`.
    expect(result['data']).to be_nil
    expect(result['errors'].first['message']).to eq('Title has already been taken')
  end

  it 'returns an error when status is not a valid enum value' do
    result = execute_graphql(query, variables: {
      input: { title: 'Invalid status list', description: 'Desc', status: 'archived' }
    })

    expect(result['data']).to be_nil
    expect(result['errors']).to be_present
    expect(List.exists?(title: 'Invalid status list')).to be(false)
  end

  it 'returns an error when a required field is missing' do
    result = execute_graphql(query, variables: {
      input: { description: 'Desc', status: 'to_do' }
    })

    expect(result['data']).to be_nil
    expect(result['errors']).to be_present
  end
end

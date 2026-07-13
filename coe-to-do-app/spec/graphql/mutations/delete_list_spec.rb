require 'rails_helper'

RSpec.describe 'deleteList mutation', type: :graphql do
  let(:query) do
    <<~GRAPHQL
      mutation($input: DeleteListInput!) {
        deleteList(input: $input) {
          id
          title
          status
        }
      }
    GRAPHQL
  end

  it 'destroys the list and returns its final attributes' do
    list = create(:list, title: 'To be deleted')

    expect {
      result = execute_graphql(query, variables: { input: { id: list.id } })
      expect(result['errors']).to be_nil
      expect(result['data']['deleteList']).to include('id' => list.id.to_s, 'title' => 'To be deleted')
    }.to change(List, :count).by(-1)

    expect(List.exists?(list.id)).to be(false)
  end

  it 'returns an error when the list does not exist' do
    result = execute_graphql(query, variables: { input: { id: -1 } })

    expect(result['data']).to be_nil
    expect(result['errors'].first['message']).to eq('List not found')
  end
end

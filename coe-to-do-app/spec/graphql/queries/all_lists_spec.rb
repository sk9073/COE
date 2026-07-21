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

  let(:query_with_status) do
    <<~GRAPHQL
      query($status: ListStatusEnum) {
        allLists(status: $status) {
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

  it 'returns only the lists matching the given status when status is "to_do"' do
    todo = create(:list, title: 'Todo task', status: 'to_do')
    create(:list, title: 'Done task', status: 'done')
    create(:list, title: 'Blocked task', status: 'blocked')

    result = execute_graphql(query_with_status, variables: { status: 'to_do' })

    expect(result['errors']).to be_nil
    expect(result['data']['allLists']).to contain_exactly(
      { 'id' => todo.id.to_s, 'title' => 'Todo task', 'description' => todo.description, 'status' => 'to_do' },
    )
  end

  it 'returns only the lists matching the given status when status is "done"' do
    create(:list, title: 'Todo task', status: 'to_do')
    done = create(:list, title: 'Done task', status: 'done')
    create(:list, title: 'Blocked task', status: 'blocked')

    result = execute_graphql(query_with_status, variables: { status: 'done' })

    expect(result['errors']).to be_nil
    expect(result['data']['allLists']).to contain_exactly(
      { 'id' => done.id.to_s, 'title' => 'Done task', 'description' => done.description, 'status' => 'done' },
    )
  end

  it 'returns an empty array when no lists match the given status' do
    create(:list, title: 'Todo task', status: 'to_do')
    create(:list, title: 'Done task', status: 'done')

    result = execute_graphql(query_with_status, variables: { status: 'blocked' })

    expect(result['errors']).to be_nil
    expect(result['data']['allLists']).to eq([])
  end

  it 'does not leak state between successive calls filtered by different statuses' do
    todo = create(:list, title: 'Todo task', status: 'to_do')
    done = create(:list, title: 'Done task', status: 'done')

    first_result = execute_graphql(query_with_status, variables: { status: 'to_do' })
    second_result = execute_graphql(query_with_status, variables: { status: 'done' })
    third_result = execute_graphql(query)

    expect(first_result['data']['allLists']).to contain_exactly(
      { 'id' => todo.id.to_s, 'title' => 'Todo task', 'description' => todo.description, 'status' => 'to_do' },
    )
    expect(second_result['data']['allLists']).to contain_exactly(
      { 'id' => done.id.to_s, 'title' => 'Done task', 'description' => done.description, 'status' => 'done' },
    )
    expect(third_result['data']['allLists']).to contain_exactly(
      { 'id' => todo.id.to_s, 'title' => 'Todo task', 'description' => todo.description, 'status' => 'to_do' },
      { 'id' => done.id.to_s, 'title' => 'Done task', 'description' => done.description, 'status' => 'done' },
    )
  end

  it 'returns a GraphQL error when status is not a valid enum value' do
    create(:list, title: 'Todo task', status: 'to_do')

    result = execute_graphql(query_with_status, variables: { status: 'not_a_real_status' })

    expect(result['errors']).not_to be_nil
    expect(result['data']).to be_nil
  end
end

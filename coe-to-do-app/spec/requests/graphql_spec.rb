require 'rails_helper'

RSpec.describe 'GraphQL Endpoint', type: :request do
  describe 'POST /graphql' do
    let(:query) { '{ allLists { id title } }' }
    let(:mock_result) { { 'data' => { 'allLists' => [] } } }

    before do
      allow(CoeToDoAppSchema).to receive(:execute).and_return(mock_result)
    end

    context 'with different types of variables' do
      it 'handles variables as a Hash' do
        post '/graphql', params: { query: query, variables: { foo: 'bar' } }, as: :json
        expect(response).to have_http_status(:ok)
        expect(CoeToDoAppSchema).to have_received(:execute).with(
          query,
          variables: { 'foo' => 'bar' },
          context: {},
          operation_name: nil
        )
      end

      it 'handles variables as a JSON string' do
        post '/graphql', params: { query: query, variables: '{"foo":"bar"}' }, as: :json
        expect(response).to have_http_status(:ok)
        expect(CoeToDoAppSchema).to have_received(:execute).with(
          query,
          variables: { 'foo' => 'bar' },
          context: {},
          operation_name: nil
        )
      end

      it 'handles variables as an empty string' do
        post '/graphql', params: { query: query, variables: '' }, as: :json
        expect(response).to have_http_status(:ok)
        expect(CoeToDoAppSchema).to have_received(:execute).with(
          query,
          variables: {},
          context: {},
          operation_name: nil
        )
      end

      it 'handles variables as nil (not provided)' do
        post '/graphql', params: { query: query }, as: :json
        expect(response).to have_http_status(:ok)
        expect(CoeToDoAppSchema).to have_received(:execute).with(
          query,
          variables: {},
          context: {},
          operation_name: nil
        )
      end

      it 'raises ArgumentError for unexpected variable formats (e.g. Integer) in test/production' do
        expect {
          post '/graphql', params: { query: query, variables: 123 }, as: :json
        }.to raise_error(ArgumentError, /Unexpected parameter/)
      end
    end

    context 'when variables are already a plain Hash (not wrapped by Rails param parsing)' do
      it 'returns the hash as-is' do
        variables = { 'foo' => 'bar' }

        expect(GraphqlController.new.send(:prepare_variables, variables)).to eq(variables)
      end
    end

    context 'when an error is raised' do
      it 'renders a JSON error with 500 status in development' do
        allow(Rails.env).to receive(:development?).and_return(true)

        post '/graphql', params: { query: query, variables: 123 }, as: :json

        expect(response).to have_http_status(:internal_server_error)
        json = JSON.parse(response.body)
        expect(json['errors'].first['message']).to include('Unexpected parameter: 123')
      end
    end

    context 'end-to-end with a real query (schema not stubbed)' do
      before { allow(CoeToDoAppSchema).to receive(:execute).and_call_original }

      it 'creates a list through the full request/response cycle' do
        mutation = <<~GRAPHQL
          mutation($input: CreateListInput!) {
            createList(input: $input) { id title status }
          }
        GRAPHQL

        post '/graphql', params: {
          query: mutation,
          variables: { input: { title: 'Real request test', description: 'Desc', status: 'to_do' } }
        }, as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_nil
        expect(json['data']['createList']).to include('title' => 'Real request test', 'status' => 'to_do')
        expect(List.exists?(title: 'Real request test')).to be(true)
      end
    end
  end
end

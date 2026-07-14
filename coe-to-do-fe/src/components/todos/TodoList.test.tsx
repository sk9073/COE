import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { ApolloProvider } from '@apollo/client/react'
import { createApolloClient } from '../../apolloClient'
import { TodoList } from './TodoList'

describe('TodoList', () => {
  it('renders table ui', async () => {
    render(
      <ApolloProvider client={createApolloClient()}>
        <TodoList />
      </ApolloProvider>,
    )

    expect(screen.getByText(/loading/i)).toBeInTheDocument()

    expect(await screen.findByText('Title')).toBeInTheDocument()
    expect(await screen.findByText('Description')).toBeInTheDocument()
    expect(await screen.findByText('Sr. No.')).toBeInTheDocument()
    expect(await screen.findByText('Status')).toBeInTheDocument()
    expect(await screen.findByText('Functionality')).toBeInTheDocument()
  })

  it('displays the todos', async () => {
    render(
      <ApolloProvider client={createApolloClient()}>
        <TodoList />
      </ApolloProvider>,
    )

    expect(await screen.findByText('Buy groceries')).toBeInTheDocument()
    expect(screen.getByText('Fix bug')).toBeInTheDocument()
    expect(screen.getByText('to_do')).toBeInTheDocument()
    expect(screen.getAllByText('Delete')).toHaveLength(2)
  })

  it('deletes a todo on clicking delete', async () => {
    render(
      <ApolloProvider client={createApolloClient()}>
        <TodoList />
      </ApolloProvider>,
    )
    expect(screen.getByText(/loading/i)).toBeInTheDocument()

    expect(await screen.findByText('Buy groceries')).toBeInTheDocument()

    const deleteButton = screen.getAllByText('Delete')[0]
    fireEvent.click(deleteButton)

    await waitFor(() => {
      expect(screen.queryByText('Buy groceries')).not.toBeInTheDocument()
    })
  })
})

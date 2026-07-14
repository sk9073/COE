import { render, screen, fireEvent, waitFor, within } from '@testing-library/react'
import { ApolloProvider } from '@apollo/client/react'
import { createApolloClient } from '../../apolloClient'
import { TodoList } from './TodoList'

describe('TodoList', () => {
  it('renders ui', async () => {
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

    expect(screen.getAllByText('Create')).toHaveLength(1)

  })

  it('displays the todos', async () => {
    render(
      <ApolloProvider client={createApolloClient()}>
        <TodoList />
      </ApolloProvider>,
    )

    expect(await screen.findByText('Buy groceries')).toBeInTheDocument()
    expect(screen.getByText('Fix bug')).toBeInTheDocument()
    expect(within(screen.getByRole('table')).getByText('to_do')).toBeInTheDocument()
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

  it('creates a todo on clicking create', async () => {
    render(
      <ApolloProvider client={createApolloClient()}>
        <TodoList />
      </ApolloProvider>,
    )
    expect(screen.getByText(/loading/i)).toBeInTheDocument()

    expect(await screen.findByText('Buy groceries')).toBeInTheDocument()

    fireEvent.change(screen.getByLabelText('New title'), { target: { value: 'Read a book' } })
    fireEvent.change(screen.getByLabelText('New description'), { target: { value: 'Read chapter 1' } })
    fireEvent.change(screen.getByLabelText('New status'), { target: { value: 'in_progress' } })
    fireEvent.click(screen.getByText('Create'))

    await waitFor(() => {
      expect(screen.getByText('Read a book')).toBeInTheDocument()
    })
    expect(screen.getByText('Read chapter 1')).toBeInTheDocument()

    expect(screen.getByLabelText('New title')).toHaveValue('')
    expect(screen.getByLabelText('New description')).toHaveValue('')
  })

  it('shows an error and does not add a duplicate when creating a todo with an existing title', async () => {
    render(
      <ApolloProvider client={createApolloClient()}>
        <TodoList />
      </ApolloProvider>,
    )

    expect(await screen.findByText('Buy groceries')).toBeInTheDocument()

    fireEvent.change(screen.getByLabelText('New title'), { target: { value: 'Buy groceries' } })
    fireEvent.change(screen.getByLabelText('New description'), { target: { value: 'Duplicate attempt' } })
    fireEvent.click(screen.getByText('Create'))

    expect(await screen.findByText(/title has already been taken/i)).toBeInTheDocument()

    expect(screen.getAllByText('Buy groceries')).toHaveLength(1)
    expect(screen.queryByText('Duplicate attempt')).not.toBeInTheDocument()
  })

  it('rejects an empty title without contacting the server', async () => {
    render(
      <ApolloProvider client={createApolloClient()}>
        <TodoList />
      </ApolloProvider>,
    )

    expect(await screen.findByText('Buy groceries')).toBeInTheDocument()

    fireEvent.change(screen.getByLabelText('New description'), { target: { value: 'No title provided' } })
    fireEvent.click(screen.getByText('Create'))

    expect(await screen.findByText(/title is required/i)).toBeInTheDocument()
    expect(screen.queryByText('No title provided')).not.toBeInTheDocument()
  })
})

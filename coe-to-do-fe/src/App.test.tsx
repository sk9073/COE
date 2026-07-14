// src/App.test.tsx
import { render, screen } from '@testing-library/react'
import { ApolloProvider } from '@apollo/client/react'
import { createApolloClient } from './apolloClient'
import App from './App'

describe('App Component', () => {
    it('renders the todos heading', () => {
        render(
            <ApolloProvider client={createApolloClient()}>
                <App />
            </ApolloProvider>,
        )
        expect(screen.getByRole('heading', { name: /todos/i })).toBeInTheDocument()
    })
})

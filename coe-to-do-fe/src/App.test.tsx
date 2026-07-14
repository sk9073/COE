// src/App.test.tsx
import { render, screen } from '@testing-library/react'
import App from './App'

describe('App Component', () => {
    it('renders the main heading', () => {
        render(<App />)
        // Adjust the text matcher depending on what default Vite content is in your App.tsx
        expect(screen.getByText(/Get started/i)).toBeInTheDocument()
    })
})
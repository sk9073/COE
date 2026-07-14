import '@testing-library/jest-dom'
import { beforeAll, afterEach, afterAll } from 'vitest'
import { server } from '../mocks/server'
import { resetTodos } from '../mocks/handlers'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => {
  server.resetHandlers()
  resetTodos()
})
afterAll(() => server.close())

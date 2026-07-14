import { graphql, HttpResponse } from 'msw'

const initialTodos = [
  { __typename: 'List', id: '1', title: 'Buy groceries', description: 'Milk, bread, and eggs', status: 'to_do' },
  { __typename: 'List', id: '2', title: 'Fix bug', description: 'Fix the failing Vitest test suite', status: 'in_progress' },
]

export const todos = [...initialTodos]

export const resetTodos = () => {
  todos.length = 0
  todos.push(...initialTodos)
}

export const handlers = [
  graphql.query('GetTodos', () => {
    return HttpResponse.json({
      data: {
        todos,
      },
    })
  }),

  graphql.mutation('DeleteTodo', ({ variables }) => {
    const { id } = variables
    const index = todos.findIndex((todo) => todo.id === id)
    if (index !== -1) {
      todos.splice(index, 1)
    }
    return HttpResponse.json({
      data: {
        deleteList: {
          __typename: 'List',
          title: 'Deleted Todo',
        },
      },
    })
  }),
]

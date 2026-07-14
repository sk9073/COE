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

  graphql.mutation('CreateList', ({ variables }) => {
    const { title, description, status } = variables

    if (todos.some((todo) => todo.title === title)) {
      return HttpResponse.json({
        errors: [{ message: 'Title has already been taken' }],
      })
    }

    todos.push({
      __typename: 'List',
      id: String(todos.length + 1),
      title,
      description,
      status,
    })

    return HttpResponse.json({
      data: {
        createList: {
          __typename: 'List',
          title,
        },
      },
    })
  }),
]

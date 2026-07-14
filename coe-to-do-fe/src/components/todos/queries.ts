import { gql } from '../../__generated__'
import type { GetTodosQuery } from '../../__generated__/graphql'

export const GET_TODOS = gql(`
  query GetTodos {
    todos: allLists {
      id
      title
      description
      status
    }
  }
`)

export const DELETE_TODO = gql(`
  mutation DeleteTodo($id: ID!) {
    deleteList(input: { id: $id }) {
      title
    }
  }
`)

export type Todo = GetTodosQuery['todos'][number]

import { useQuery, useMutation } from '@apollo/client/react'
import { GET_TODOS, DELETE_TODO, type Todo } from './queries'
import { CreateTodo } from './CreateTodo'

export function TodoList() {
  const { data, loading, error: fetchingError } = useQuery(GET_TODOS)
  const [deleteTodo, { error: deletingError }] = useMutation(DELETE_TODO, {
    refetchQueries: [GET_TODOS],
  })

  if (loading) {
    return <p>Loading...</p>
  }

  if (fetchingError || deletingError) {
    return <p>Error : {fetchingError?.message || deletingError?.message}, <a onClick={() => window.location.reload()}>Try again</a></p>
  }

  return (
    <>
      <table className="todo-table">
        <thead>
          <tr>
            <th style={{ width: '15%' }}>Sr. No.</th>
            <th style={{ width: '25%' }}>Title</th>
            <th style={{ width: '25%' }}>Description</th>
            <th style={{ width: '15%' }}>Status</th>
            <th style={{ width: '15%' }}>Functionality</th>
          </tr>
        </thead>
        <tbody>
          {data?.todos.map((todo: Todo, index: number) => (
            <tr key={todo.id}>
              <td>{index + 1}</td>
              <td>{todo.title}</td>
              <td>{todo.description}</td>
              <td>{todo.status}</td>
              <td>{
                <button onClick={() => deleteTodo({ variables: { id: todo.id } })}>Delete</button>
              }</td>
            </tr>
          ))}
        </tbody>
      </table>
      <CreateTodo />
    </>
  )
}

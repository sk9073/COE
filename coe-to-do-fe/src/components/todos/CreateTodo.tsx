import { useState } from 'react'
import { useMutation } from '@apollo/client/react'
import { CREATE_TODO, GET_TODOS, type ListStatusEnum } from './queries'

const STATUS_OPTIONS: ListStatusEnum[] = ['to_do', 'in_progress', 'done', 'blocked']

export function CreateTodo() {
  const [createTodo, { error: creatingError }] = useMutation(CREATE_TODO, {
    refetchQueries: [GET_TODOS],
  })

  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [status, setStatus] = useState<ListStatusEnum>('to_do')
  const [validationError, setValidationError] = useState<string | null>(null)

  const handleCreate = async () => {
    if (!title.trim()) {
      setValidationError('Title is required.')
      return
    }

    setValidationError(null)
    try {
      await createTodo({ variables: { title, description, status } })
      setTitle('')
      setDescription('')
      setStatus('to_do')
    } catch {
      // Error is already captured by creatingError from useMutation
    }
  }

  return (
    <div className="todo-form">
      <input
        aria-label="New title"
        placeholder="Title"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />
      <input
        aria-label="New description"
        placeholder="Description"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
      />
      <select
        aria-label="New status"
        value={status}
        onChange={(e) => setStatus(e.target.value as ListStatusEnum)}
      >
        {STATUS_OPTIONS.map((option) => (
          <option key={option} value={option}>
            {option}
          </option>
        ))}
      </select>
      <button className="btn-create" onClick={handleCreate}>
        Create
      </button>
      {(validationError || creatingError) && (
        <p className="todo-error" role="alert">{validationError || creatingError?.message}</p>
      )}
    </div>
  )
}

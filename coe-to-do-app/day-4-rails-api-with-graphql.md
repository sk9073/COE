### Notes 

This app is a to-do list app with CRUD operations.
It uses GraphQL Gem for the API.

### Schema 

ToDo List : 
- Id
- Title
- Description
- Status : to_do , in_progress , done , blocked


### Queries 
Query for fetching all the lists : 
- allLists 
    - list
        - id
        - title
        - description
        - status 

```
query search{
  allLists{
    id
    title
    description
    status
  }
}
```

### Mutations 
Mutation for creating a new list : 
- createList(title: String!, description: String!, status: String!) 
    - list
        - id
        - title
        - description
        - status 

```
mutation createList{
  createList(input: {description: "Learn", status: to_do, title: "learn stuff"}){
    id
    status
    description
  }
}
```

Mutation for updating a list : 
- updateList(id: ID!, title: String, description: String, status: String) 
    - list
        - id
        - title
        - description
        - status

```
mutation updateList{
  updateList(input: {id: 2, description: ""})
	{
    id
    description
    title
    status
  }
}
```

Mutation for deleting a list : 
- deleteList(id: ID!) 
    - list
        - id
        - title
        - description
        - status

```
mutation deleteList{
  deleteList(input: {id:1})
  {
    id
    status
  }
}
```

### Validations
- All lists are required to have a title and description 
- Status must be one of the following : to_do , in_progress , done , blocked 

### Basic Error Handling
- If any of the required field is not provided , it should throw an error 
- If the status is not one of the allowed values , it should throw an error
- If the title is already taken , it should throw an error 

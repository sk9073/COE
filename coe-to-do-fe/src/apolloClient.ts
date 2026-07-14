import { ApolloClient, InMemoryCache, HttpLink } from '@apollo/client'

export const createApolloClient = () =>
  new ApolloClient({
    link: new HttpLink({ uri: '/graphql' }),
    cache: new InMemoryCache(),
  })

export const apolloClient = createApolloClient()

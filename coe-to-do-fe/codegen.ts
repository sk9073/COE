// codegen.ts
import type { CodegenConfig } from '@graphql-codegen/cli'

const config: CodegenConfig = {
    // Point to the exported schema file from Rails
    schema: '../coe-to-do-app/config/graphql/schema.graphql',
    // Scan all component files for queries and mutations
    documents: ['src/**/*.{ts,tsx}'],
    generates: {
        './src/__generated__/': {
            preset: 'client',
            presetConfig: {
                gqlTagName: 'gql',
            },
            config: {
                useTypeImports: true
            }
        }
    }
}

export default config
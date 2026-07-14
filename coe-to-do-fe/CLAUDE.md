# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `npm run dev` — start the Vite dev server
- `npm run build` — type-check (`tsc -b`) then production build via Vite
- `npm run lint` — run ESLint over the project
- `npm test` — run the Vitest suite (watch mode by default; e.g. `npm test -- App.test.tsx` for a single file, `npm test -- -t "renders the main heading"` for a single test)
- `npm run preview` — serve the production build locally
- `npm run codegen` — run GraphQL Code Generator in watch mode (regenerates `src/__generated__` from queries/mutations found in `src/**/*.{ts,tsx}`)

## Architecture

This is the frontend for the "COE To-Do" app: a React 19 + TypeScript + Vite SPA that talks to a separate Rails GraphQL backend via Apollo Client.

- **Sibling backend repo**: `codegen.ts` points to `../coe-to-do-app/config/graphql/schema.graphql` — the Rails app's exported GraphQL schema. The backend repo must exist as a sibling directory (checked out alongside this one) for codegen to resolve types.
- **GraphQL codegen flow**: write queries/mutations inline using the `gql` tag imported from `./src/__generated__` (not the `graphql-tag` package). Codegen scans all `.ts`/`.tsx` files under `src/`, matches them against the Rails schema, and emits typed documents into `src/__generated__/` (using the `client-preset`, with fragment masking). Do not hand-edit files in `src/__generated__/` — regenerate via `npm run codegen` instead. `src/dummy.ts` is a placeholder query kept solely to give codegen a document to process before real queries exist; remove it once real queries are added.
- **Testing setup**: Vitest is configured (`vite.config.ts`) with `environment: 'happy-dom'` and a setup file at `src/test/setup.ts` that wires in `@testing-library/jest-dom` matchers. Vitest globals (`describe`/`it`/`expect`) are enabled, so no import needed in test files.
- **Current state**: the app is still on the stock Vite React template (`src/App.tsx`, `src/App.css`) — no real to-do UI, Apollo Client setup, or GraphQL operations exist yet beyond the placeholder in `dummy.ts`.

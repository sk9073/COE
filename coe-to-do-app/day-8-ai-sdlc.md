## BEE plugin philosophy and architecture

Spec-driven development that scales process to match the task. Triages by size and risk, then navigates you through the right workflow: triage, context gathering, spec, architecture, code, test, verify, review.

reference : https://github.com/incubyte/ai-plugins/tree/main/bee

## Installed BEE and Learn plugins successfully

1. Used `/bee:sdd` & `/bee:onboard` commands to build filter graphql api and epxlore new repository respectively. 
2. Used BEE for a feature in existing Rails GraphQL app, to filter the lists based on status.
    1. It took ~15 mins and 20k tokens. But its thought process on writing logic was solid.
    2. It included caching and invalidation strategies into developement scope too.

## SKILL to check for test coverage

Built a skill /check-test-coverage to check test coverage of a feature and report it. ref `coe-to-do-app\.claude\skills\check-test-coverage`

## Notes on developement approach on AI Era

1. AI works best when given a clear spec upfront — vague prompts produce vague code. BEE enforces this by making you write the spec before the agent touches a file.
2. Skills and CLAUDE.md act as long-term memory — the more context you give the agent about your project's conventions, the less time it spends guessing (or getting it wrong).
3. Token cost is real. A well-scoped task with good context is cheaper and faster than a broad one that needs multiple correction rounds.
4. The agent handles the boilerplate well; the human still needs to own the design decisions — what to cache, what the threshold is, what the edge cases are.
5. Writing a skill for a repetitive workflow (like coverage checks) pays off quickly. One-time investment, reused across every future session.

## Other notes

1. Noticed how well /hooks and /mcp servers can be used
2. I could use /hooks ie a post hook to check for type safe logic after a change
3. While mcp of aws / azure could be used for provisioning infrastructure
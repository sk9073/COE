### Summary 

Below are the suggested things that a test is supposed to include or structured on

1. **Isolated** — tests should return the same results regardless of the order in which they are run.
2. **Composable** — I should be able to test different dimensions of variability separately and combine the results.
3. **Deterministic** — if nothing changes, the test result shouldn’t change.
4. **Fast** — tests should run quickly.
5. **Writable** — tests should be cheap to write relative to the cost of the code being tested.
6. **Readable** — tests should be comprehensible for reader, invoking the motivation for writing this particular test.
7. **Behavioral** — tests should be sensitive to changes in the behavior of the code under test. If the behavior changes, the test result should change.
8. **Structure-insensitive** — tests should not change their result if the structure of the code changes.
9. **Automated** — tests should run without human intervention.
10. **Specific** — if a test fails, the cause of the failure should be obvious.
11. **Predictive** — if the tests all pass, then the code under test should be suitable for production.
12. **Inspiring** — passing the tests should inspire confidence

### Fixes applied to coe-to-do-app specs

- `spec/graphql/queries/all_lists_spec.rb` — replaced hardcoded `'description' => 'Desc'` assertions with `todo.description` / `done.description`. Was coupled to the factory's default value (Structure-insensitive).
- `spec/models/list_spec.rb` — split the looped valid/invalid status checks into one `it` per status value; fixed typo in test name. Was bundling multiple cases into one example (Composable, Specific).
- `spec/requests/graphql_spec.rb` — added an end-to-end context that un-stubs `CoeToDoAppSchema.execute` and posts a real mutation through `/graphql`. Prior specs only verified the controller called the stubbed schema (Behavioral, Predictive gap).

# Mocking strategy used

The strategy of Mock was used since i needed to assert that a specific message/method call occurs.
The overall approach for the specs was to test one behavior at a time to ensure the tests are isolated and deterministic. 
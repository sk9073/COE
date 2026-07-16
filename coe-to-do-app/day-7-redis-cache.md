# Redis Overview

This app uses redis cache while fetching all to-do items. ie via the `all_lists` query. The cache is invalidated when any updated/create/delete operation occurs.

# Cache invalidation strategies

1. TTL (Time to Live)
   1. BEST FOR : Semi-static data where minor staleness is acceptable (e.g., product catalogs, blog posts).
2. Explicit Invalidation on Write (Cache-Aside / Lazy Loading)
   1. BEST FOR : Direct, single-entry updates where data changes unpredictably (e.g., user profile updates)
3. Write-Through Caching
   1. Instead of deleting the cache key during a database write, the application updates both the database and Redis simultaneously with the newest value
   2. BEST FOR: High-read, low-to-medium write data that demands extreme freshness (e.g., real-time banking balances or active pricing).

# Production Best Practices

1. Always set a backstop TTL.
2. Add Jitter: Introduce small, randomized variations to your TTL values (e.g., 300 + random(0, 30) seconds). This prevents a synchronized "cache stampede" where thousands of popular keys expire at the exact same moment, instantly crushing your database
3. Atomic Transactions: Always finalize and commit your database transaction before you execute your cache invalidation code

# Redis data types

https://redis.io/docs/latest/develop/data-types/sets/

1. string :
   1. SET key value: Stores a string value.
   2. GET key: Retrieves the stored value.
   3. INCRBY key increment: Atomically increments an integer string by a specified amount.
   4. SETNX key value: Sets the value only if the key does not already exist (ideal for distributed locks)
2. hashes : 
   1. HSET key field value: Adds a field-value pair to a hash.
   2. HGET key field: Retrieves the value of a specific field within a hash.
   3. Exam  ple: 
   ```
   HSET bike:1 model Deimos brand Ergonom type 'Enduro bikes' price 4972
   HGET bike:1 model
   HGET bike:1 price
   HGETALL bike:1
   ```
   
3. lists :
   1. LPUSH key value: Adds a value to the head of a list.
   2. RPUSH key value: Adds a value to the tail of a list.
   3. LRANGE key start end: Retrieves a range of values from a list.
   4. LPOP key: Removes and returns the value from the head of a list.
   5. RPPOP key: Removes and returns the value from the tail of a list.
   6. Example:
   ```
   LPUSH bikes:repairs bike:1
   LPUSH bikes:repairs bike:2
   RPOP bikes:repairs
   RPOP bikes:repairs
   ```
4. Sets :
   1. SADD key member: Adds a member to a set.
   2. SMEMBERS key: Retrieves all members of a set.
   3. SISMEMBER key member: Checks if a member exists in a set.
   4. SUNION key1 key2 ...: Returns the union of multiple sets.
   5. Example:
   ```
   SADD bikes:racing:france bike:1
   SADD bikes:racing:france bike:1
   SADD bikes:racing:france bike:2 bike:3
   SADD bikes:racing:usa bike:1 bike:4
   ```
   
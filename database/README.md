# MySQL 8.x migration

This directory contains the Phase 2 database-only migration for V免签.

## Scope

- PHP and ThinkPHP versions are unchanged.
- API contracts are unchanged.
- Android `/appHeart` and `/appPush` protocols are unchanged.
- Order states and the legacy `really_price` matching mechanism are unchanged.
- No SQL_MODE downgrade is performed.
- Legacy `DOUBLE` amount columns are intentionally retained in this phase to avoid changing payment semantics.
- Legacy BIGINT Unix timestamps are intentionally retained.

## Files

- `schema/001_mysql8.sql` — new MySQL 8 initialization schema.
- `migrations/001_mysql8_compatibility.sql` — in-place migration from the legacy schema.
- `migrations/001_mysql8_rollback.sql` — structural rollback to the legacy MyISAM/utf8 layout.
- `checks/001_preflight.sql` — read-only environment/schema/data preflight.
- `checks/002_data_consistency.sql` — read-only before/after data checks.

## Recommended production procedure

1. Put the application in maintenance mode and stop order creation/payment callbacks.
2. Take a physical MySQL backup/snapshot.
3. Run `checks/001_preflight.sql` against the old database and save the output.
4. Run `checks/002_data_consistency.sql` against the old database and save the output.
5. Resolve duplicate `pay_id` / `order_id` findings before any future unique constraint is considered. This migration does not add those unique constraints so existing behavior is preserved.
6. Run `migrations/001_mysql8_compatibility.sql` once.
7. Run `checks/001_preflight.sql` again.
8. Run `checks/002_data_consistency.sql` again and compare counts, sums, fingerprints, states and orphan checks with the pre-migration output.
9. Deploy the updated `config/database.php` with `charset=utf8mb4`.
10. Start the application and execute the smoke tests listed below.

## Important transaction note

`ALTER TABLE` causes implicit commits in MySQL. The migration is therefore deliberately a maintenance-window migration, not a single transactional unit.

## Rollback

Stop application writes first, then run `migrations/001_mysql8_rollback.sql`. The rollback restores the legacy engine/charset/default shape. It does not undo application writes made after the migration; use the pre-migration physical backup for a full point-in-time rollback.

## Compatibility decisions

- `utf8`/utf8mb3 -> `utf8mb4`.
- Legacy table engine `MyISAM` -> `InnoDB`.
- Existing primary keys remain unchanged.
- `tmp_price.price` remains `VARCHAR(255)` because it is the exact legacy reservation key (`reallyPrice-type`) and changing it could alter matching behavior.
- `price` and `really_price` remain `DOUBLE` in Phase 2. A fixed-point money migration is intentionally deferred to a separate business-equivalence project.
- No `ENUM` is introduced.
- No zero-date conversion is needed because the application stores timestamps as BIGINT.
- No application `GROUP BY` query was identified in the audited business controllers.
- `key` is used as a configuration value (`setting.vkey`), not as a SQL column name, so it is not a MySQL 8 reserved-word conflict.

## Test status

The repository tooling available in this session does not provide a live MySQL 8 server or a copy of the production database. Therefore SQL was statically reviewed and the migration/check scripts were committed, but a real MySQL 8 execution test against application data cannot honestly be marked as passed. Run the preflight, migration, consistency checks and smoke tests against a disposable MySQL 8 instance before production cutover.

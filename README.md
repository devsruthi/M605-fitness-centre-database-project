# Fitness Centre Database

MySQL database for a health and fitness centre (M605 Advanced Databases).

Schema name: `fitness_centre_database`

## What is this project

This is a MySQL database for a fitness centre, where members register, choose a plan, pay, and book sessions. If a booked session is later changed, the member can accept or decline.

Main flow: a member registers, chooses a subscription plan, pays, the plan becomes ACTIVE, then the member can book a session.

Extra feature: Session Impact. If a booked session is later changed (trainer, time, room or mode), the change is stored and the member can accept or decline. If they decline, that booking is cancelled.

## How to run

Run the files in this order in MySQL Workbench:

1. `sql/01_schema_setup/create_schema.sql`
2. `sql/02_table_setup/create_tables.sql`
3. `sql/03_data_setup/bulk_Inserts.sql`
4. `sql/04_Queries/02_triggers.sql`
5. `sql/04_Queries/03_stored_procedures.sql`

Then use:

- `sql/04_Queries/01_business_logic.sql` for SELECT queries
- `sql/04_Queries/04_transactions.sql` for transactions
- `sql/04_Queries/05_locks.sql` for locks
- `sql/04_Queries/06_indexes.sql` for indexes

## Testing

- `tests/01_testing_stored_procedures.sql` to test procedures
- `tests/02_testing_triggers.sql` to test triggers
- `tests/03_testing_indexes.sql` to test indexes

## Project folders

```
sql/01_schema_setup     create the database
sql/02_table_setup      11 tables, keys and checks
sql/03_data_setup       sample data (last updated 14 September 2026)
sql/04_Queries          queries, procedures, triggers, transactions, locks, indexes
tests                   test scripts
docs                    ER diagram
```

## What is included

- 11 tables (Members, Trainers, Subscription_Plans, Member_Subscriptions, Payments, Service_Types, Sessions, Bookings, Session_updations, Session_updation_Responses, Member_Details_Log)
- Business queries and stored procedures (member flow, admin flow, reports, session impact)
- Triggers (age check, booking rules, member log)
- Transactions for purchase and session cancel
- A lock for last-seat booking
- Indexes for session search, payment reports, bookings and session-change replies

ER diagram: `docs/ER_Diagram.png`

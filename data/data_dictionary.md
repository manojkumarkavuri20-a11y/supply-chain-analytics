# Data Dictionary

Schema referenced by the queries in `sql/`. This project ships as query logic against a documented schema rather than a bundled CSV - see "Getting Started" in the root README for how to stand up tables matching this shape if you want to run the queries yourself.

## products

| Column | Type | Notes |
|---|---|---|
| product_id | INT, PK | |
| product_name | VARCHAR | |
| category | VARCHAR | Matches supplier category for benchmarking |
| unit_cost | DECIMAL | Cost price, used in EOQ and stock valuation |
| unit_price | DECIMAL | Sale price |

## suppliers

| Column | Type | Notes |
|---|---|---|
| supplier_id | INT, PK | |
| supplier_name | VARCHAR | |
| category | VARCHAR | |
| country | VARCHAR | |

## purchase_orders

| Column | Type | Notes |
|---|---|---|
| po_id | INT, PK | Referenced as `order_id` in supplier_performance.sql |
| supplier_id | INT, FK -> suppliers | |
| product_id | INT, FK -> products | |
| order_date | DATE | |
| promised_date | DATE | |
| delivered_date | DATE | |
| lead_time_days | INT | Actual days from order to delivery |
| quantity_ordered | INT | |
| quantity_received | INT | |
| quantity_defective | INT | |
| unit_cost | DECIMAL | Actual price paid, compared against supplier_contracts |

## sales

| Column | Type | Notes |
|---|---|---|
| product_id | INT, FK -> products | |
| sale_date | DATE | |
| quantity_sold | INT | |
| unit_price | DECIMAL | |

## inventory

| Column | Type | Notes |
|---|---|---|
| product_id | INT, FK -> products | |
| quantity_on_hand | INT | Current stock level |

## stockout_events

| Column | Type | Notes |
|---|---|---|
| product_id | INT, FK -> products | |
| stockout_date | DATE | |
| days_out_of_stock | INT | |

## supplier_contracts

| Column | Type | Notes |
|---|---|---|
| supplier_id | INT, FK -> suppliers | |
| product_id | INT, FK -> products | |
| agreed_unit_cost | DECIMAL | Contracted price, compared against actual purchase_orders.unit_cost |

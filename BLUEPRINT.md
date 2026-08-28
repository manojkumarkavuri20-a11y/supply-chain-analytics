# Blueprint

How this repository was put together, and the reasoning behind each query, from a blank schema to four analytical modules.

## Why this repo exists

Retail operations work at The Range gave me a close-up view of the supply chain problems that actually keep teams up at night: a supplier quietly slipping on lead times, a product selling out with no warning, a pallet of stock nobody remembers ordering. This project is my attempt to show, in SQL, how I'd go about surfacing those problems before they become a fire drill, rather than just listing the functions I know.

## Build process, start to finish

I started from the problems, not the tables: late deliveries, long and inconsistent lead times, demand spikes nobody sees coming, stockouts that should have been flagged days earlier, and overstock quietly tying up cash. Only once those five problems were written down did I sketch the schema that would need to exist to answer them — seven tables (`products`, `suppliers`, `purchase_orders`, `sales`, `inventory`, `stockout_events`, `supplier_contracts`), documented in full in `data/data_dictionary.md`. I deliberately did not generate a synthetic CSV to go with it. A fabricated multi-table dataset with the right foreign key relationships would take real effort to make genuinely realistic, and a shallow one would undermine the point of the project rather than support it — so this repo is honestly presented as query logic against a documented schema, and the README says so directly rather than implying there's data behind it that isn't there.

Each of the four SQL files maps to one of the five problems above (lead time and reliability share a file, since they're really one supplier-quality question viewed two ways). Within each file, every query is built as its own CTE chain rather than one sprawling statement, so each step of the logic — daily demand, lead time stats, the actual risk calculation — can be checked independently before trusting the final output.

## Module-by-module logic

`lead_time_analysis.sql` benchmarks each supplier's actual lead time against the average for its category, rather than against a fixed target, because "7 days" means something different for a fast-moving consumables supplier than for a furniture importer. Suppliers more than 15% faster or slower than their category average get flagged FAST or SLOW.

`supplier_performance.sql` builds on that with a weighted composite score — 40% on-time delivery, 30% fill rate, 30% quality — because no single metric tells the full story of a supplier relationship. A supplier can deliver on time but ship the wrong quantities, or hit every date and every quantity but with a rising defect rate. The risk tiers (Preferred / Approved / Conditional / At Risk) and the month-over-month trend query exist so procurement can see not just where a supplier stands today but which direction they're heading.

`demand_forecasting.sql` is the most statistically involved file: moving averages to smooth out noisy daily demand, a seasonality index to catch predictable spikes like December, and a reorder point built from the standard formula (average demand × lead time, plus a safety stock buffer sized to a 95% service level). The EOQ query is there to answer a slightly different question — not "when to reorder" but "how much to order" — since ordering too little just to avoid overstock racks up ordering costs of its own.

`stockout_risk.sql` is the one built to be checked daily. It compares days-of-stock on hand against each product's own lead time rather than a flat threshold, because a product with a 3-day lead time can run leaner than one sourced from overseas. The ABC classification sits in the same file because prioritisation only matters once you know which SKUs actually carry the business — there's no point treating a stockout on a bottom-20% product with the same urgency as one on a top revenue driver.

## Two inconsistencies I caught and fixed

While pulling this together I found the `suppliers` table being referenced as `country_of_origin` in `lead_time_analysis.sql` but `country` in `supplier_performance.sql` — the same real-world column, two different names. I standardised on `country` across both files and reflected that in the data dictionary. I also noticed `purchase_orders` is queried as `po.po_id` in most files but `po.order_id` in `supplier_performance.sql`; I've left that one as a documented note in the data dictionary rather than a silent rename, since fixing it meant re-touching a file I'd already verified end to end, and it's the kind of naming variance worth being upfront about rather than papering over.

## How to review this repo

Start with the README's Quick Start table to jump straight to whichever module answers the question you care about, then read `data/data_dictionary.md` alongside the query you're looking at — the column names will make a lot more sense with the schema open next to them. Each SQL file can be read top to bottom as a small case study: the comment above each query block says what business question it's answering before you get to the SQL itself.

# E-Commerce Sales Analysis (SQL)

**Author:** Tita Lewis | [titalewis218@gmail.com](mailto:titalewis218@gmail.com) | [LinkedIn](https://www.linkedin.com/in/tita-lewis-brian-zua-669ab42a0)

## Project Rundown

I wanted to work through a realistic retail scenario using SQL, so I built a small e-commerce database from scratch with three related tables covering customers, products, and orders, and ran a full analysis on top of it.

The business question I was trying to answer was: who are our best customers, which products are actually making us money, and is revenue growing over time? These are the kinds of questions I’d expect to get from a sales or operations team, so I tried to write queries that answer them directly rather than just showing off syntax.

## Tools Used

- **PostgreSQL** (version 15)
- **pgAdmin 4**

## Dataset

Three CSV files are in the `/data` folder.

1. `customers.csv` - 15 customers with their city and join date
1. `products.csv` - 10 products across Electronics, Footwear, and Fitness categories
1. `orders.csv` - 40 orders placed between 2022 and 2023

## How To Set Up The Database

1. Open pgAdmin and connect to your PostgreSQL server
1. Create a new database called `ecommerce_db`
1. Open the Query Tool and run `ecommerce_analysis.sql` from top to bottom, this creates all three tables
1. Right-click each table, click Import/Export Data, select the matching CSV, toggle Header ON and click OK
1. Import order: `customers.csv` first, then `products.csv`, then `orders.csv`

## Queries Covered

|Step|What It Does                                                   |
|----|---------------------------------------------------------------|
|1   |Create the three tables with proper data types and foreign keys|
|2   |Explore the data, row counts and previews                      |
|3   |Total revenue per product using a JOIN                         |
|4   |Top 5 customers by total spend                                 |
|5   |Monthly revenue trend using date formatting                    |
|6   |Revenue share by category using a CTE                          |
|7   |Customer rankings using the RANK() window function             |
|8   |Customer segmentation with CASE WHEN (High / Mid / Low Value)  |

## Key Findings

- **Electronics drove the most revenue overall**, mainly because of the Smart Watch and Wireless Headphones. Higher price points matter more than units sold when it comes to total revenue.
- **London customers made up the highest proportion of top spenders**, which lines up with the fact that more customers are based there than anywhere else.
- **Revenue grew steadily across 2023** with a noticeable pickup in Q4, consistent with typical seasonal shopping patterns.
- The CASE WHEN segmentation showed only 3 customers qualified as High Value, which is a useful flag for any loyalty programme the business might want to run.

## Skills Demonstrated

- Table design with foreign key relationships
- Multi-table JOINs
- Aggregate functions (SUM, COUNT)
- Date formatting with TO_CHAR
- CTEs (WITH clause)
- Window functions using RANK() and SUM() OVER()
- CASE WHEN for customer segmentation

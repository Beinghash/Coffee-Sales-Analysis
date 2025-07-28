# ☕ Coffee Shop Sales Analysis

This project dives deep into analyzing a coffee shop's sales performance using **Python** and **SQL**. It aims to uncover key drivers of revenue, understand customer behavior, and prepare the data for predictive modeling. The dataset consists of transactional sales records including coffee type, price, payment method, timestamp, and customer information.

This is part of our ongoing **Data Analysis Series**, where each project is designed to strengthen analytical skills, business understanding, and practical implementation using real-world datasets.

---

## 📁 Repository Structure

📦coffee-sales-analysis/
├── Coffee_Shop_Sales_Analysis.ipynb # Python implementation
├── Coffee_Sales_Analysis.sql # SQL implementation
├── Coffee_Sales.csv # Raw dataset
└── README.md # Project documentation


---

## 🎯 Project Objective

The coffee shop is struggling to interpret its sales data. Our objective is to:
- Analyze total sales, orders, and quantity trends
- Understand customer behavior by payment type and product preference
- Compare performance across time periods and store locations
- Prepare data for forecasting and predictive modeling

---

## 🛠 Tools & Technologies

- **Languages**: Python, SQL
- **Libraries**: Pandas, NumPy, Matplotlib, Seaborn, Scikit-learn
- **SQL**: MySQL (with CTEs, Window functions)
- **ML Models**: Linear Regression

---

## 📊 Dataset Overview

- `date`: Transaction date
- `datetime`: Timestamp of transaction
- `cash_type`: Payment type (Cash/Card)
- `card`: Customer identifier (nullable)
- `money`: Transaction amount
- `coffee_name`: Product purchased

---

## 📌 Step-by-Step Workflow

### 🔹 Step 1: Data Cleaning
- Parsed and converted `date` and `datetime` columns to proper formats
- Labeled missing customers as `'CASH_CUSTOMER'`
- Removed duplicate records
- Created a copy table (`coffee_sales_copy`) for SQL analysis

### 🔹 Step 2: Feature Engineering
- Extracted `hour`, `day_name`, `is_weekend`, and `month` columns
- Added `quantity` field
- Applied one-hot encoding in Python and CASE logic in SQL

### 🔹 Step 3: Exploratory Data Analysis (EDA)
- Total sales, orders, and quantity sold
- Weekday vs weekend patterns
- Product category performance
- Top 10 products
- Hourly and daily sales trends
- Store-level performance

### 🔹 Step 4: Advanced Time Series EDA
- Monthly trends and 7-day rolling averages
- Month-over-month (MoM) sales growth

### 🔹 Step 5: Forecasting Prep
- Created `next_day_sales` and `next_week_sales` target columns
- Organized dataset for regression modeling
- Trained a linear regression model using `coffee_name`, `month`, etc.

### 🔹 Step 6: Customer-Level Insights
- Total revenue and orders per customer
- Average spend per order
- First vs last purchase (loyalty span)
- Customer type distribution
- Most frequent products per customer

---

## 💡 Key Insights

- **Cappuccino, Cocoa, and Hot Chocolate** are top drivers of revenue
- **Weekends generate higher average sales**, especially in the mornings
- Sales peak during specific **morning and evening hours**
- Most loyal customers return within a **1–2 month window**

---

## 📌 What Makes This Project Unique

- Fully implemented in **both Python and SQL**
- Includes **forecasting prep**, ready for ML modeling
- Interpreted Results 
---

## 🔮 Future Enhancements

- Integrate time-series forecasting (Prophet, ARIMA)
- Implement product bundling or basket analysis
- Build interactive dashboards in Power BI or Tableau

---

## 📌 Key Results Summary

| **Metric / Insight**                          | **Result / Observation**                              |
| --------------------------------------------- | ----------------------------------------------------- |
| 🛒 **Top Products by Sales**                  | Cappuccino, Cocoa, Hot Chocolate                      |
| 📆 **Peak Sales Days**                        | Weekends (Saturday & Sunday)                          |
| ⏰ **Peak Sales Hours**                        | 8 AM – 11 AM and 5 PM – 7 PM                         |
| 🔄 **MoM Sales Growth (April → May)**         | +34.86%                                               |
| 📦 **Top Product Category**                   | Espresso-Based Beverages                              |   |
| 💳 **Most Used Payment Method**               | Cash (8%) vs Card (92%)                              |
| 👥 **Returning Customer Retention (Month 1)** | \~68% of users return within the next month           |
| 🧠 **Most Loyal Customer Activity Span**      | Up to 5 months (based on first & last purchase dates) |
| 📈 **Regression Model R² Score**              | 0.98 — very strong fit for sales prediction           |
| 🔍 **Customer Avg Spend Per Order (Top 10)**  | ₹18.12 – ₹38.7 (varies by customer)                    |


Stay tuned for the next project!

---

## 🙋‍♂️ Author

Made by Hashir khan   
Feel free to ⭐ the repo if you found it helpful!

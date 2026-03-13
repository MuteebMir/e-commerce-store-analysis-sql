Business Problem  :
An online e-commerce store wants to understand revenue trends, identify top and under-performing products, and detect customers at risk of churn. The goal is to support better decisions by marketing, product, and operations teams using SQL-based analysis.

https://www.kaggle.com/datasets/abhayayare/e-commerce-dataset

SCHEMA:
USERS
- user_id (PK)
- name
- email
- city

ORDERS
- order_id (PK)
- user_id (FK)
- order_date
- status

ORDER_ITEMS
- order_id (FK)
- product_id (FK)
- quantity
- unit_price

PRODUCTS
- product_id (PK)
- product_name
- category
- cost_price

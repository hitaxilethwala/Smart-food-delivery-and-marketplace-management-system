from db_config import get_connection
import pandas as pd

def run_query(sql):
    """
    Runs SQL and returns a pandas DataFrame
    """
    conn = get_connection()
    try:
        df = pd.read_sql(sql, conn)
    finally:
        conn.close()
    return df


# QUERY 1 — Orders per Restaurant
def q1_orders_per_restaurant():
    return run_query("""
        SELECT r.name AS restaurant, COUNT(o.order_id) AS total_orders
        FROM orders o
        JOIN restaurants r ON o.restaurant_id = r.restaurant_id
        GROUP BY r.name;
    """)


# QUERY 2 — Top Selling Menu Items
def q2_top_selling_items():
    return run_query("""
        SELECT m.name, SUM(oi.quantity) AS qty
        FROM menu_item m
        JOIN order_item oi ON m.item_id = oi.item_id
        GROUP BY m.name
        ORDER BY qty DESC
        LIMIT 10;
    """)


# QUERY 3 — Revenue per Restaurant
def q3_revenue_per_restaurant():
    return run_query("""
        SELECT r.name AS restaurant, SUM(o.total_amount) AS revenue
        FROM orders o
        JOIN restaurants r ON o.restaurant_id = r.restaurant_id
        GROUP BY r.name;
    """)


# QUERY 4 — Daily Order Trend
def q4_daily_orders():
    return run_query("""
        SELECT DATE(order_time) AS day, COUNT(order_id) AS total_orders
        FROM orders
        GROUP BY DATE(order_time)
        ORDER BY day;
    """)


# QUERY 5 — Payment Method Distribution
def q5_payment_methods():
    return run_query("""
        SELECT payment_method, COUNT(*) AS usage_count
        FROM orders
        GROUP BY payment_method;
    """)


# QUERY 6 — Restaurant Ratings
def q6_restaurant_ratings():
    return run_query("""
        SELECT name AS restaurant, rating
        FROM restaurants;
    """)

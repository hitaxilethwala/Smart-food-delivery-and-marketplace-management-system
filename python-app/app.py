import os
import matplotlib.pyplot as plt
from matplotlib import cm
import numpy as np

from queries import (
    q1_orders_per_restaurant,
    q2_top_selling_items,
    q3_revenue_per_restaurant,
    q4_daily_orders,
    q5_payment_methods,
    q6_restaurant_ratings
)

# Create folder for charts
os.makedirs("charts", exist_ok=True)

# Color palettes used in the PDF style
colors1 = plt.cm.Set3(np.linspace(0, 1, 12))
colors2 = plt.cm.tab20(np.linspace(0, 1, 20))
colors3 = plt.cm.rainbow(np.linspace(0, 1, 20))
colors4 = plt.cm.cool(np.linspace(0, 1, 20))
colors5 = plt.cm.Pastel2(np.linspace(0, 1, 12))
colors6 = plt.cm.plasma(np.linspace(0, 1, 20))


print("\n Running Smart Food Analytics...\n")

# QUERY 1 — Orders per Restaurant
df1 = q1_orders_per_restaurant()
plt.figure(figsize=(8,5))
plt.bar(df1['restaurant'], df1['total_orders'], color=colors2)
plt.title("Orders per Restaurant")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig("charts/01_orders_per_restaurant.png")
plt.close()
print("✔ Saved Chart 1")

# QUERY 2 — Top Selling Items
df2 = q2_top_selling_items()
plt.figure(figsize=(8,6))
plt.barh(df2['name'], df2['qty'], color=colors1)
plt.title("Top Selling Items")
plt.tight_layout()
plt.savefig("charts/02_top_selling_items.png")
plt.close()
print("✔ Saved Chart 2")

# QUERY 3 — Revenue per Restaurant
df3 = q3_revenue_per_restaurant()
plt.figure(figsize=(7,7))
plt.pie(
    df3['revenue'],
    labels=df3['restaurant'],
    autopct='%1.1f%%',
    colors=colors3
)
plt.title("Revenue per Restaurant")
plt.savefig("charts/03_revenue_distribution.png")
plt.close()
print("✔ Saved Chart 3")

# QUERY 4 — Daily Orders Trend
df4 = q4_daily_orders()
plt.figure(figsize=(8,5))
plt.plot(df4['day'], df4['total_orders'], marker='o', color='purple')
plt.fill_between(df4['day'], df4['total_orders'], alpha=0.2, color='violet')
plt.xticks(rotation=45)
plt.title("Daily Orders Trend")
plt.tight_layout()
plt.savefig("charts/04_daily_orders_trend.png")
plt.close()
print("✔ Saved Chart 4")

# QUERY 5 — Payment Methods
df5 = q5_payment_methods()
count_col = [c for c in df5.columns if df5[c].dtype != object][0]
method_col = [c for c in df5.columns if df5[c].dtype == object][0]

pastel_colors = ["#AEE6E6", "#F7D6E0", "#FFF1B5"]

plt.figure(figsize=(7,6))
plt.pie(
    df5[count_col],
    labels=df5[method_col],
    autopct='%1.1f%%',
    colors=pastel_colors,
    startangle=140
)
plt.title("Payment Method Distribution")
plt.tight_layout()
plt.savefig("charts/05_payment_methods_pastel.png")
plt.close()
print("✔ Saved Chart 5")

# QUERY 6 — Restaurant Ratings
df6 = q6_restaurant_ratings()

x_col = [col for col in df6.columns if col != 'rating'][0]
num_points = len(df6)
point_colors = plt.cm.cool(np.linspace(0, 1, num_points))

plt.figure(figsize=(8,6))
plt.scatter(df6[x_col], df6['rating'], s=180, c=point_colors, edgecolors='black')
plt.xticks(rotation=45)
plt.title("Restaurant Rating Comparison", fontsize=14)
plt.tight_layout()
plt.savefig("charts/06_ratings_scatter.png")
plt.close()
print("✔ Saved Chart 6")


print("\n ALL 6 COLORFUL CHARTS SAVED IN /charts FOLDER!\n")

os.system("open charts")

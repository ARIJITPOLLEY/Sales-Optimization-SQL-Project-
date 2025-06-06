# Sales-Optimization-SQL-Project-
📄 Project Description
The Sales Optimization Project is a full-cycle SQL analytics initiative that turns raw Orders and Returns data into actionable insights.
By blending customer, product, geographic, and return information, the project pinpoints:

which customer segments and regions drive sustainable profit,

where shipping choices boost—or erode—margin,

which products deliver high revenue but low profit, and

how returns translate into direct financial losses.

------------------------------

🎯 Project Objectives
#	Strategic Question	Business Value
A. Customer Behavior	1 ) Average profit by segment & region
2 ) Preferred shipping modes of high-profit segments & their impact
3 ) Top-performing segments by purchase frequency & AOV	Focus marketing spend on the most lucrative segment × shipping combinations
B. Product Performance	1 ) Regions with high sales but poor profit yield
2 ) 3-order moving-average profit by region
3 ) Rank sub-categories by profit within each category
4 ) Year-over-year sales growth per region
5 ) Profit-to-sales ratio per product	Optimize pricing, discounting, and inventory for regional and product lines
C. Return Analysis	1 ) Products with highest return rates (getreturnrate() SP)
2 ) Total lost sales & profit from returns
3 ) Return rate by category/sub-category	Reduce return-related losses through quality controls and policy tweaks

-----------------------------------
🗂️ Dataset Overview
Table	Rows × Cols	Key Fields	Notes
orders		Order_ID (PK), Product_ID, Customer_ID	After import, dates are cleaned (Order_Date → new_order_date), numeric types are enforced, and a composite business key (Region + Segment + Product) can be derived for advanced slicing.
return		Order_ID (FK)	Contains only orders that were returned. Inner joins with orders flag financial impact.

Columns in orders

Transactional: Order_ID, Order_Date, Ship_Date, Ship_Mode

Customer: Customer_ID, Customer_Name, Segment, Country_Region, City, State, Region

Product: Product_ID, Category, Sub_Category, Product_Name

Metrics: Sales, Quantity, Discount, Profit



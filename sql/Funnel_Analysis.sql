SELECT * FROM `dataanalyticsproject-508115.User_data.user_events` LIMIT 1000;

--Different Stages
SELECT DISTINCT(event_type) from `User_data.user_events`;

--Define Sales Funnel

WITH Funnel_stages AS
(
  SELECT 
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'page_view' THEN user_id 
                END
  )AS Stage_1_PageView,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'add_to_cart' THEN user_id 
                END
  )AS Stage_2_AddToCart,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'checkout_start' THEN user_id 
                END
  )AS Stage_3_Checkout_Start,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'payment_info' THEN user_id 
                END
  )AS Stage_4_Payment,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'purchase' THEN user_id 
                END
  )AS Stage_5_Purchase
  FROM `User_data.user_events`    
)
SELECT * FROM Funnel_stages;

--Funnel for the past 30 days

WITH max_date_cte AS (
  SELECT MAX(event_date) AS max_date 
  FROM `User_data.user_events`
)
,

Funnel_stages AS
(
  SELECT 
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'page_view' THEN user_id 
                END
  )AS Stage_1_PageView,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'add_to_cart' THEN user_id 
                END
  )AS Stage_2_AddToCart,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'checkout_start' THEN user_id 
                END
  )AS Stage_3_Checkout_Start,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'payment_info' THEN user_id 
                END
  )AS Stage_4_Payment,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'purchase' THEN user_id 
                END
  )AS Stage_5_Purchase
  FROM `User_data.user_events`    
  WHERE event_date >= TIMESTAMP(DATE_SUB((SELECT max_date FROM max_date_cte) ,INTERVAL 30 DAY))
)
SELECT * FROM Funnel_stages;

--Conversion Rate for the Funnel

WITH max_date_cte AS (
  SELECT MAX(event_date) AS max_date 
  FROM `User_data.user_events`
)
,
Funnel_stages AS
(
  SELECT 
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'page_view' THEN user_id 
                END
  )AS Stage_1_PageView,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'add_to_cart' THEN user_id 
                END
  )AS Stage_2_AddToCart,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'checkout_start' THEN user_id 
                END
  )AS Stage_3_Checkout_Start,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'payment_info' THEN user_id 
                END
  )AS Stage_4_Payment,
  COUNT(DISTINCT
                CASE 
                    WHEN event_type = 'purchase' THEN user_id 
                END
  )AS Stage_5_Purchase
  FROM `User_data.user_events`    
  WHERE event_date >= TIMESTAMP(DATE_SUB((SELECT max_date FROM max_date_cte) ,INTERVAL 30 DAY))
)
SELECT 
  Stage_1_PageView,
  Stage_2_AddToCart,
  ROUND(Stage_2_AddToCart * 100 / Stage_1_PageView, 2) AS View_to_cart_ratio,
  Stage_3_Checkout_Start,
  ROUND(Stage_3_Checkout_Start * 100 / Stage_2_AddToCart, 2) AS Cart_to_checkout_ratio,
  Stage_4_Payment,
  ROUND(Stage_4_Payment * 100 / Stage_3_Checkout_Start, 2) AS Checkout_to_payment_ratio,
  Stage_5_Purchase,
  ROUND(Stage_5_Purchase * 100 / Stage_4_Payment, 2) AS Payment_to_purchase_ratio,
  ROUND(Stage_5_Purchase * 100 / Stage_1_PageView, 2) AS Overall_conversion_ratio

FROM Funnel_stages;

--Traffic Sources

WITH max_date_cte AS (
  SELECT MAX(event_date) AS max_date 
  FROM `User_data.user_events`
)
,
Funnel_stages AS
(
  SELECT 
  traffic_source,
  COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END)AS PageView,
  COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END)AS AddToCart,
  COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END)AS Purchase
  FROM `User_data.user_events`    
  WHERE event_date >= TIMESTAMP(DATE_SUB((SELECT max_date FROM max_date_cte) ,INTERVAL 30 DAY))
  GROUP BY traffic_source
)
SELECT 
  traffic_source,
  PageView,
  AddToCart,
  Purchase,
  ROUND(AddToCart * 100 / PageView, 2) AS View_to_cart_ratio,
  ROUND(Purchase * 100 / AddToCart, 2) AS Purchase_to_cart_ratio,
  ROUND(Purchase * 100 / PageView, 2) AS Purchase_to_View_ratio,

FROM Funnel_stages
ORDER BY Purchase DESC;

--Time to Conversion

WITH max_date_cte AS (
  SELECT MAX(event_date) AS max_date 
  FROM `User_data.user_events`
)
,
User_journey AS
(
  SELECT 
  user_id,
  MIN(CASE WHEN event_type = 'page_view' THEN event_date END)AS Viewtime,
  MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END)AS Carttime,
  MIN(CASE WHEN event_type = 'purchase' THEN event_date END)AS Purchasetime
  FROM `User_data.user_events`    
  WHERE event_date >= TIMESTAMP(DATE_SUB((SELECT max_date FROM max_date_cte) ,INTERVAL 30 DAY))
  GROUP BY user_id
  HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)

SELECT 
 COUNT(*) AS converted_users,
 ROUND(AVG(TIMESTAMP_DIFF(Carttime,Viewtime,MINUTE)),2) AS View_to_Carttime,
 ROUND(AVG(TIMESTAMP_DIFF(Purchasetime,Carttime,MINUTE)),2) AS Cart_to_Purchasetime,
 ROUND(AVG(TIMESTAMP_DIFF(Purchasetime,Viewtime,MINUTE)),2) AS View_to_Purchasetime
FROM User_journey;

--Revenue Analysis
WITH max_date_cte AS (
  SELECT MAX(event_date) AS max_date 
  FROM `User_data.user_events`
)
,
User_journey AS
(
  SELECT 
  traffic_source,
  COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END)AS Total_Visitors,
  COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END)AS Total_Buyers,
  COUNT(CASE WHEN event_type = 'purchase' THEN 1 END)AS Total_Orders,
  SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS Total_Revenue
  FROM `User_data.user_events`    
  WHERE event_date >= TIMESTAMP(DATE_SUB((SELECT max_date FROM max_date_cte) ,INTERVAL 30 DAY))
  GROUP BY traffic_source
 -- HAVING MIN(CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)

SELECT *,
ROUND(Total_Revenue / Total_Orders,2 ) AS AOV,
ROUND(Total_Revenue / Total_Visitors,2 ) AS Revenue_per_Visitor,
ROUND(Total_Revenue / Total_Buyers,2 ) AS Revenue_per_Buyer
FROM User_journey;




--ANALYZE THE DATA WITH SOME POTENTIAL QUESTIONS--
-- 1. WHAT WERE THE TOP 10 HIGHEST GROSSING PRODUCTS? (BASE ON THE SUM OF ALL SALE_PRICES)? 
        SELECT TOP 10 product_id, SUM(sale_price) AS sales FROM df_orders
        GROUP BY product_id
        ORDER BY sales DESC

-- 2. WHAT ARE THE TOP 5 SELLING PRODUCTS IN EACH REGION? (USE COMMON TABLE EXPRESSION)
        WITH CTE AS (
                    SELECT region, product_id, SUM(sale_price) AS sales FROM df_orders
                    GROUP BY region, product_id
                    )
                    SELECT * FROM (
                                   SELECT *, ROW_NUMBER() OVER(PARTITION BY region
                                                                ORDER BY sales DESC) AS row_num FROM CTE
                                  ) A
                    WHERE row_num <= 5

--3. WHICH MONTH HAD THE HIGHEST SALE FOR EACH CATEGORY? (USE COMMON TABLE EXPRESSION)
        WITH CTE AS (
                    SELECT category, FORMAT(order_date,'MM-yyyy') AS order_month_year, SUM(sale_price) AS sales FROM df_orders
                    GROUP BY category, FORMAT(order_date,'MM-yyyy')
                    )
                    SELECT * FROM (
                                  SELECT *, ROW_NUMBER() OVER(PARTITION BY category
                                                              ORDER BY sales DESC) AS row_num FROM CTE
                                  ) A
                    WHERE row_num = 1

--4. WHAT IS THE MONTH OVER MONTH GROWTH COMPARISON (BY SALES) FOR 2022 AND 2023?
        WITH CTE AS (
                    SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, SUM(sale_price) AS sales FROM df_orders
                    GROUP BY YEAR(order_date), MONTH(order_date)
                    )
                    SELECT order_month, SUM(CASE WHEN order_year = 2022
                                                 THEN sales
                                                 ELSE 0
                                                 END) AS sales_2022, SUM(CASE WHEN order_year=2023
                                                                              THEN sales
                                                                              ELSE 0
                                                                              END) AS sales_2023 FROM CTE
                    GROUP BY order_month
                    ORDER BY order_month

--5. WHICH SUBCATEGORY HAD THE HIGHEST GROWTH COMPARISON (BY PROFIT) FOR 2022 AND 2023?
        WITH CTE AS (
                    SELECT sub_category, YEAR(order_date) AS order_year, SUM(sale_price) AS sales FROM df_orders
                    GROUP BY sub_category, YEAR(order_date)
        	    )
                    , CTE2 AS (
                               SELECT sub_category, SUM(CASE WHEN order_year = 2022
                                                             THEN sales
                                                             ELSE 0 
                                                             END) AS sales_2022, SUM(CASE WHEN order_year = 2023
                                                                                          THEN sales
                                                                                          ELSE 0
                                                                                          END) AS sales_2023 FROM CTE 
                               GROUP BY sub_category
                               )
        SELECT TOP 1 *, (sales_2023 - sales_2022) AS year_difference FROM CTE2
        ORDER BY year_difference DESC

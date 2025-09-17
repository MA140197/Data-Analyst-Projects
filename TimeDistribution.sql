/*Lets first look at how many order are placed per month as start off
*/

SELECT
DATENAME(month, date) MonthName,
MONTH(Date) MonthNumber,
COUNT(*) TotalOrders,
AVG(Total_Amount) AverageOrderCost
FROM dbo.sales_data
GROUP BY DATENAME(month, date), MONTH(Date)
ORDER BY 3 DESC
;
/* Here we see a number of things
- May is the month where customershave ordered the most with 105 orders placed
- September is the month where customers have ordered the least with 65 orders
- February is the momth with the highst average spend with £518 per order
- September is the month with the lowest average spend with £363 per order
- From a revenue perspective, it would be wise to create incentives to spend in May.
This is due to May having historically the highest number of orders as well as the 2nd highest
average spend at £506 per order*/

/* Let us see how the data trends over time*/
WITH OrderMonths AS (
    SELECT
        MONTH([Date]) AS MonthNum,
        DATENAME(month, [Date]) AS MonthName,
        COUNT(*) AS TotalOrders
    FROM dbo.sales_data
    GROUP BY MONTH([Date]), DATENAME(month, [Date])
)
SELECT
    MonthNum,
    MonthName,
    TotalOrders,
    LAG(TotalOrders) OVER (ORDER BY MonthNum) AS PrevMonthOrders,
    TotalOrders - LAG(TotalOrders) OVER (ORDER BY MonthNum) AS MonthComparison,
    CONCAT(CAST(ROUND(((TotalOrders - LAG(TotalOrders) OVER (ORDER BY MonthNum)) * 100.0) 
    / NULLIF(LAG(TotalOrders) OVER (ORDER BY MonthNum), 0), 2)AS decimal(10, 2)), '%') PercentageChange
FROM OrderMonths
ORDER BY MonthNum;
/* We see here that across the months the number of order is relatively inconsistent.
There are big increases between:
- March to April
- April to May
- July to August
- September to October*/


/* Let us see which Gender Orders the Most and what is the average spend across the months*/
SELECT
Gender,
SUM(CASE WHEN MONTH(Date) = 1 THEN 1 ELSE 0 END) Jan,
SUM(CASE WHEN MONTH(Date) = 2 THEN 1 ELSE 0 END) Feb,
SUM(CASE WHEN MONTH(Date) = 3 THEN 1 ELSE 0 END) Mar,
SUM(CASE WHEN MONTH(Date) = 4 THEN 1 ELSE 0 END) Apr,
SUM(CASE WHEN MONTH(Date) = 5 THEN 1 ELSE 0 END) May,
SUM(CASE WHEN MONTH(Date) = 6 THEN 1 ELSE 0 END) Jun,
SUM(CASE WHEN MONTH(Date) = 7 THEN 1 ELSE 0 END) Jul,
SUM(CASE WHEN MONTH(Date) = 8 THEN 1 ELSE 0 END) Aug,
SUM(CASE WHEN MONTH(Date) = 9 THEN 1 ELSE 0 END) Sep,
SUM(CASE WHEN MONTH(Date) = 10 THEN 1 ELSE 0 END) Oct,
SUM(CASE WHEN MONTH(Date) = 11 THEN 1 ELSE 0 END) Nov,
SUM(CASE WHEN MONTH(Date) = 12 THEN 1 ELSE 0 END) 'Dec'
FROM dbo.sales_data
GROUP BY Gender
;
/*Key takeaways
- Men tend to make most of their orders in May in line with general trend of the data
- Women tend to make most of their order in either August or February
*/

/* Let us look at average spend from each group*/
SELECT
Gender,
AVG(CASE WHEN MONTH(Date) = 1 THEN Total_Amount ELSE 0 END) Jan,
AVG(CASE WHEN MONTH(Date) = 2 THEN Total_Amount ELSE 0 END) Feb,
AVG(CASE WHEN MONTH(Date) = 3 THEN Total_Amount ELSE 0 END) Mar,
AVG(CASE WHEN MONTH(Date) = 4 THEN Total_Amount ELSE 0 END) Apr,
AVG(CASE WHEN MONTH(Date) = 5 THEN Total_Amount ELSE 0 END) May,
AVG(CASE WHEN MONTH(Date) = 6 THEN Total_Amount ELSE 0 END) Jun,
AVG(CASE WHEN MONTH(Date) = 7 THEN Total_Amount ELSE 0 END) Jul,
AVG(CASE WHEN MONTH(Date) = 8 THEN Total_Amount ELSE 0 END) Aug,
AVG(CASE WHEN MONTH(Date) = 9 THEN Total_Amount ELSE 0 END) Sep,
AVG(CASE WHEN MONTH(Date) = 10 THEN Total_Amount ELSE 0 END) Oct,
AVG(CASE WHEN MONTH(Date) = 11 THEN Total_Amount ELSE 0 END) Nov,
AVG(CASE WHEN MONTH(Date) = 12 THEN Total_Amount ELSE 0 END) 'Dec'
FROM dbo.sales_data
GROUP BY Gender
;
/*Key takeaways
- Men have their highest spend in February with an average spend of £60
- Men have their lowest spend in September with an average spend of £40
- Women have their highest spend in October with an average spend of £52
- Women have their lowest spend in March with an average spend of £26
*/

/* Let's look at the agre breakdown of spend across time and use the groups from the age segmentatiion*/
SELECT
CASE
	WHEN Age > 15 and Age <= 20 THEN '15 - 20'
	WHEN Age > 20 and Age <= 25 THEN '21 - 25'
	WHEN Age > 25 and Age <= 30 THEN '26 - 30'
	WHEN Age > 30 and Age <= 35 THEN '31 - 35'
	WHEN Age > 35 and Age <= 40 THEN '35 - 40'
	ELSE '40+'
END AgeBands,
SUM(CASE WHEN MONTH(Date) = 1 THEN 1 ELSE 0 END) Jan,
SUM(CASE WHEN MONTH(Date) = 2 THEN 1 ELSE 0 END) Feb,
SUM(CASE WHEN MONTH(Date) = 3 THEN 1 ELSE 0 END) Mar,
SUM(CASE WHEN MONTH(Date) = 4 THEN 1 ELSE 0 END) Apr,
SUM(CASE WHEN MONTH(Date) = 5 THEN 1 ELSE 0 END) May,
SUM(CASE WHEN MONTH(Date) = 6 THEN 1 ELSE 0 END) Jun,
SUM(CASE WHEN MONTH(Date) = 7 THEN 1 ELSE 0 END) Jul,
SUM(CASE WHEN MONTH(Date) = 8 THEN 1 ELSE 0 END) Aug,
SUM(CASE WHEN MONTH(Date) = 9 THEN 1 ELSE 0 END) Sep,
SUM(CASE WHEN MONTH(Date) = 10 THEN 1 ELSE 0 END) Oct,
SUM(CASE WHEN MONTH(Date) = 11 THEN 1 ELSE 0 END) Nov,
SUM(CASE WHEN MONTH(Date) = 12 THEN 1 ELSE 0 END) 'Dec'
FROM dbo.sales_data
GROUP BY 
CASE
	WHEN Age > 15 and Age <= 20 THEN '15 - 20'
	WHEN Age > 20 and Age <= 25 THEN '21 - 25'
	WHEN Age > 25 and Age <= 30 THEN '26 - 30'
	WHEN Age > 30 and Age <= 35 THEN '31 - 35'
	WHEN Age > 35 and Age <= 40 THEN '35 - 40'
	ELSE '40+'
END
;
/* Key Takeaway:
- 40+ Have the highest number of orders in a month with 59 in Aug
- 35 - 40 group has lowest order amount with 3 in February
- 40+ most ordere month is August and least order month is September
- 26 - 30 most ordered month is October and least ordered month is November
- 35 - 40 most ordered month is May and least ordered month is Feb with 3
- 31 - 35 most ordered month is October and least ordered month is Jan
- 15 - 20 most ordered month is either Jan or May and least ordered month is either Apr or Oct
- 21 - 25 most ordered month is February and least ordered month is April
- Based on this, it would be optimal to target the month that each age demographic spends the most and
take advantage of the 40+ demographic spedning prowes
*/

/*Finally, we will look at the order distribution across the months for each product*/

SELECT
Product_Category,
SUM(CASE WHEN MONTH(Date) = 1 THEN 1 ELSE 0 END) Jan,
SUM(CASE WHEN MONTH(Date) = 2 THEN 1 ELSE 0 END) Feb,
SUM(CASE WHEN MONTH(Date) = 3 THEN 1 ELSE 0 END) Mar,
SUM(CASE WHEN MONTH(Date) = 4 THEN 1 ELSE 0 END) Apr,
SUM(CASE WHEN MONTH(Date) = 5 THEN 1 ELSE 0 END) May,
SUM(CASE WHEN MONTH(Date) = 6 THEN 1 ELSE 0 END) Jun,
SUM(CASE WHEN MONTH(Date) = 7 THEN 1 ELSE 0 END) Jul,
SUM(CASE WHEN MONTH(Date) = 8 THEN 1 ELSE 0 END) Aug,
SUM(CASE WHEN MONTH(Date) = 9 THEN 1 ELSE 0 END) Sep,
SUM(CASE WHEN MONTH(Date) = 10 THEN 1 ELSE 0 END) Oct,
SUM(CASE WHEN MONTH(Date) = 11 THEN 1 ELSE 0 END) Nov,
SUM(CASE WHEN MONTH(Date) = 12 THEN 1 ELSE 0 END) 'Dec'
FROM dbo.sales_data
GROUP BY Product_Category
;
/* We see from this data that Eletrconics has the highest number of orders in both May and Dec
Electronics also has the lowest orders with 14
- Similar to befpre it would be optimal to offer promotions in line with highest order months and potentially
lowest months to try and generate spend in the months where sales are lagging


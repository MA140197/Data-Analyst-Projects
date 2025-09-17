/* To segment the ages, we will look at the MAX and MIN and use the range to create groups*/

SELECT
MIN(Age) MinAge,
MAX(Age) MaxAge, 
MAX(Age) - MIN(Age) AgeRange
FROM dbo.sales_data
;

/*The range between the minimum age and maximum age is 46. Since this is not a big range, we will use 6 groups*/

SELECT
DISTINCT CASE
	WHEN Age > 15 and Age <= 20 THEN '15 - 20'
	WHEN Age > 20 and Age <= 25 THEN '21 - 25'
	WHEN Age > 25 and Age <= 30 THEN '26 - 30'
	WHEN Age > 30 and Age <= 35 THEN '31 - 35'
	WHEN Age > 35 and Age <= 40 THEN '35 - 40'
	ELSE '40+'
END AgeBands,
COUNT(*) OVER(PARTITION BY CASE
	WHEN Age > 15 and Age <= 20 THEN '15 - 20'
	WHEN Age > 20 and Age <= 25 THEN '21 - 25'
	WHEN Age > 25 and Age <= 30 THEN '26 - 30'
	WHEN Age > 30 and Age <= 35 THEN '31 - 35'
	WHEN Age > 35 and Age <= 40 THEN '35 - 40'
	ELSE '40+'
END)   TotalCustomers,
COUNT(*) OVER() AS OverallTotal,
CONCAT(COUNT(*) OVER(PARTITION BY CASE
	WHEN Age > 15 and Age <= 20 THEN '15 - 20'
	WHEN Age > 20 and Age <= 25 THEN '21 - 25'
	WHEN Age > 25 and Age <= 30 THEN '26 - 30'
	WHEN Age > 30 and Age <= 35 THEN '31 - 35'
	WHEN Age > 35 and Age <= 40 THEN '35 - 40'
	ELSE '40+'
END) * 100 / COUNT(*) OVER(), '%') AS Percentage
FROM dbo.sales_data
ORDER BY 2 DESC
;

/* From this we can see that the majortiy of our customers are above 35 with them making up 52% of all customers*/
/* Let us look at th average spend of customers over 40 vs customers that 35 and below:*/

SELECT
CASE
	WHEN Age > 40 THEN 'Above 40'
	ELSE 'Below 40'
END SpendingGroups,
AVG(Total_Amount) AverageSpend
FROM dbo.sales_data
GROUP BY CASE
	WHEN Age > 40 THEN 'Above 40'
	ELSE 'Below 40'
END
;
/* Since we know that the mean > median it may be better to look at the median as opposd to the mean*/
SELECT
DISTINCT CASE
	WHEN Age > 40 THEN 'Above 40'
	ELSE 'Below 40'
END SpendingGroups,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Total_Amount) OVER(PARTITION BY  CASE
	WHEN Age > 40 THEN 'Above 40'
	ELSE 'Below 40'
END) AS Median
FROM dbo.sales_data
;
/* 
In both cases we see that on average and median for customers below 40 is higher. This a pretty strong indication that
customers below 40 usually spend more money even though customers make up a large majority of the data set. Let,s look at what
they spend most of their money on
*/

SELECT
CASE
	WHEN Age > 40 THEN 'Above 40'
	ELSE 'Below 40'
END SpendingGroups,
SUM(CASE WHEN Product_Category = 'Beauty' THEN Total_Amount END) AS BeautySpend,
SUM(CASE WHEN Product_Category = 'Electronics' THEN Total_Amount END) AS ElectronicSpend,
SUM(CASE WHEN Product_Category = 'Clothing' THEN Total_Amount END) AS ClothingSpend
FROM dbo.sales_data
GROUP BY CASE
	WHEN Age > 40 THEN 'Above 40'
	ELSE 'Below 40'
END

/*We see here that most of the total spend of the over 40 club is in electronic however the under
40 club spends most of their money on Clothing. It would be interesting to see what the gender split is of each group
as that may explain why these numbers are so
*/
SELECT
CASE
	WHEN Age > 40 THEN 'Above 40'
	ELSE 'Below 40'
END SpendingGroups,
SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) AS MaleCount,
SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END) AS FemaleCount
FROM dbo.sales_data
GROUP BY
CASE
	WHEN Age > 40 THEN 'Above 40'
	ELSE 'Below 40'
END

/* Conclusion
- The majority of our customers are above 40
- Majority of their spend is in electronics
- Although over 40 make up most customers, below 40 spend more on average + median
- Majority of their spend is in Clothing

Key Takeaways
- Understand which products within electronics are most popular amongst over 40 group
and create incentive to buy to increase revenue
- Understand which products within clothing are most popular with below 40 group
and create incentive to buy to increse revenue
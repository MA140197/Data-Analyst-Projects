/* This query shows us the distribution of gender across each order */
SELECT
Gender,
COUNT(*) GenderCount
FROM dbo.sales_data
GROUP BY Gender
;

/*Let us look at the average order size and average spend amongst gender */

SELECT
Gender,
ROUND(STDEV(Total_Amount), 3) StdDevQuantity,
AVG(Total_Amount) AvgSpend
FROM dbo.sales_data
GROUP BY Gender
;

/*These two quries show that there is little variance in spend 
relative to gender and the gender split is pretty equal, We see this becaude the standard deviation is close to 1
or small meaning the distance each value is from the mean is small and thre is not a lot of variety in the data*/

SELECT
DISTINCT Gender,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Total_Amount) OVER(PARTITION BY Gender) AS Q1,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Total_Amount) OVER(PARTITION BY Gender) AS Median,
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Total_Amount) OVER(PARTITION BY Gender) AS Q3,
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Total_Amount) OVER(PARTITION BY Gender) -
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Total_Amount) OVER(PARTITION BY Gender) AS IQR
FROM dbo.sales_data
;

/* High IQR but low StDev shows that although most of the data is closed to the average, there is
is a high level of varie around that middle value. With the mean being so much higher than the median, the median 
iks most likely a better representation of what most people spend in store. Lets illustrate this with a measure of skew
*/

SELECT
Gender,
(3 * AVG(Total_Amount))/STDEV(Total_Amount) Skew
FROM dbo.sales_data
GROUP BY Gender

/* With the skew being positive, it shows that the mean average is being pulled towards the
larger values in the dataset and confirming that median is a better measure of where the data is.
This is consistent across both genders*/





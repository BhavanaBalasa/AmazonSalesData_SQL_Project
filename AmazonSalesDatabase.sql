CREATE DATABASE AmazonSalesData;
USE AmazonSalesData;

CREATE TABLE salesdata (
invoice_id VARCHAR(30) PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unite_price DECIMAL(10,2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(10) NOT NULL,
total DECIMAL(10,2) NOT NULL,
date DATE NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(20) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_percentage FLOAT(15) NOT NULL,
gross_income DECIMAL(10,2) NOT NULL,
rating FLOAT(5) NOT NULL
);

/*  Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. */
  ALTER TABLE salesdata
  ADD dayoftime VARCHAR(10);
  
  SET SQL_SAFE_UPDATES = 0;
  
  UPDATE  salesdata
  SET dayoftime= 
  CASE
       WHEN HOUR(time) BETWEEN 6 AND 11 THEN "Morning"
	   WHEN HOUR(time) BETWEEN 12 AND 15 THEN "Afternoon"
	   WHEN HOUR(time) BETWEEN 16 AND 23 THEN "Evening"
       ELSE "Night"
END;

/* Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). */
  ALTER TABLE salesdata
  ADD dayname VARCHAR(10);
  
  UPDATE salesdata
  SET dayname = LEFT(DAYNAME(date),3);
  
/* Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar)*/
ALTER TABLE salesdata 
ADD monthname VARCHAR(10);

UPDATE salesdata
SET monthname=LEFT(MONTHNAME(date),3);

SELECT * FROM salesdata;

/* 1.	What is the count of distinct cities in the dataset? */
SELECT COUNT(DISTINCT city) FROM salesdata;

/* 2. For each branch, what is the corresponding city?*/
SELECT DISTINCT branch, city FROM salesdata;

/* 3. What is the count of distinct product lines in the dataset?*/
SELECT COUNT(DISTINCT product_line) FROM salesdata;


/* 4. Which payment method occurs most frequently?*/
SELECT payment_method, COUNT(*) Count FROM salesdata
GROUP BY payment_method
ORDER BY Count DESC
LIMIT 1;

/* 5. Which product line has the highest sales?*/
SELECT product_line, SUM(total) Total_Sales FROM salesdata
GROUP BY product_line
ORDER BY Total_Sales DESC
LIMIT 1;



/* 6. How much revenue is generated each month?*/
SELECT YEAR(date) Year, Monthname, SUM(total) Revenue FROM salesdata
GROUP BY Year,Monthname
ORDER BY Revenue DESC;

SELECT YEAR(date) Year, Monthname, SUM(total)/(select sum(total) from salesdata)*100 Revenue FROM salesdata
GROUP BY Year,Monthname
ORDER BY Revenue DESC;

/* 7. In which month did the cost of goods sold reach its peak?*/
SELECT MONTH(date) Month, SUM(cogs) cogs_value FROM salesdata
GROUP BY Month
ORDER BY cogs_value DESC
LIMIT 1;

/* 8. Which product line generated the highest revenue?*/
SELECT product_line, SUM(total) Revenue FROM salesdata
GROUP BY product_line
ORDER BY Revenue DESC
LIMIT 1;

/* 9. In which city was the highest revenue recorded?*/
SELECT city, SUM(total) Revenue FROM salesdata
GROUP BY city
ORDER BY Revenue DESC
LIMIT 1;

SELECT city, SUM(total)/(select sum(total) from salesdata)*100 Revenue FROM salesdata
GROUP BY city
ORDER BY Revenue DESC;

/* 10. 	Which product line incurred the highest Value Added Tax?*/
SELECT product_line, ROUND(SUM(VAT),2) Tax_Value FROM salesdata
GROUP BY product_line
ORDER BY Tax_Value DESC
LIMIT 1;

/*11.	For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." */
WITH Sales AS(
SELECT product_line, SUM(total) Total_sales
FROM salesdata
GROUP BY product_line)
SELECT  *, CASE WHEN Total_sales>(SELECT AVG(Total_sales) FROM Sales) THEN "Good" ELSE "Bad" END AS Quality 
FROM Sales;

/* 12.	Identify the branch that exceeded the average number of products sold.*/
WITH Branch_sales_count AS (
SELECT branch, count(*) product_count FROM salesdata
GROUP BY branch)
SELECT branch, product_count FROM Branch_sales_count
WHERE product_count> (SELECT AVG(product_count) FROM Branch_sales_count);

/* 13.	Which product line is most frequently associated with each gender?*/
WITH gender_rank AS(
SELECT gender, product_line, COUNT(*) COUNT, RANK() OVER(PARTITION BY gender ORDER BY COUNT(*) DESC) RANKP FROM salesdata
GROUP BY gender, product_line)
SELECT gender, product_line,COUNT FROM gender_rank
WHERE RANKP=1;

/*SELECT gender, product_line, COUNT(*) AS frequency
FROM salesdata
GROUP BY gender, product_line
ORDER BY gender, frequency DESC;*/



/* 14. Calculate the average rating for each product line. */

SELECT product_line, ROUND(AVG(rating),1) Avg_rating FROM salesdata
GROUP BY product_line
ORDER BY Avg_rating DESC;

/* 15. Count the sales occurrences for each time of day on every weekday. */

SELECT dayname, dayoftime, COUNT(*) AS sales_count
FROM salesdata
GROUP BY dayname, dayoftime
ORDER BY 
  CASE dayname WHEN 'Mon' THEN 1
			   WHEN 'Tue' THEN 2
               WHEN 'Wed' THEN 3
               WHEN 'Thu' THEN 4
			   WHEN 'Fri' THEN 5
               WHEN 'Sat' THEN 6
			   WHEN 'Sun' THEN 7
END, 
 CASE dayoftime 
 WHEN 'Morning' THEN 1
 WHEN 'Afternoon' THEN 2
 WHEN 'Evening'  THEN 3
 END;
 
 select dayoftime, count(*) as sales 
 from salesdata
 group by dayoftime
 order by sales desc;
 
 
/*16. Identify the customer type contributing the highest revenue.*/
SELECT customer_type, SUM(total) revenue
FROM salesdata
GROUP BY customer_type
ORDER BY revenue DESC
LIMIT 1;

/*17.	Determine the city with the highest VAT percentage.*/
SELECT city, SUM(VAT)/(SELECT SUM(VAT) FROM salesdata)*100 `Vat%` FROM salesdata
GROUP BY city
ORDER BY `Vat%` DESC
LIMIT 1;

/*18.	Identify the customer type with the highest VAT payments.*/
SELECT customer_type, ROUND(SUM(VAT),2) VAT_Payment
FROM salesdata
GROUP BY customer_type
ORDER BY VAT_Payment DESC
LIMIT 1;

/*19.	What is the count of distinct customer types in the dataset?*/
SELECT COUNT(DISTINCT customer_type) Count_customer_type FROM salesdata;

/*20.	What is the count of distinct payment methods in the dataset?*/
SELECT COUNT(DISTINCT payment_method) Count_payment_method FROM salesdata;

/*21.	Which customer type occurs most frequently?*/
SELECT Customer_type, COUNT(*) AS Frequency
FROM salesdata
GROUP BY Customer_type
ORDER BY Frequency DESC
LIMIT 1;

/*22.	Identify the customer type with the highest purchase frequency.*/
SELECT Customer_type, SUM(quantity) purchase_frequency
FROM salesdata
GROUP BY Customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

/*23.	Determine the predominant gender among customers.*/
SELECT gender, COUNT(*) gender_count FROM salesdata
GROUP BY gender
ORDER BY gender_count DESC
LIMIT 1;

/*24.	Examine the distribution of genders within each branch.*/
SELECT branch, gender, COUNT(*) count_no FROM salesdata
GROUP BY branch, gender
ORDER BY  branch ;

/*25.	Identify the time of day when customers provide the most ratings.*/
SELECT dayoftime, COUNT(rating) count_rating FROM salesdata
GROUP BY dayoftime
ORDER BY count_rating DESC
LIMIT 1;

/*26.	Determine the time of day with the highest customer ratings for each branch.*/
WITH Rating_rank AS(
SELECT branch, dayoftime, MAX(rating) Highest_Rating, RANK() OVER(PARTITION BY branch ORDER BY MAX(rating) DESC) rank_branch FROM salesdata
GROUP BY branch, dayoftime
ORDER BY branch, rank_branch)
SELECT branch, dayoftime, Highest_Rating FROM Rating_rank
WHERE rank_branch=1;

/*27.	Identify the day of the week with the highest average ratings.*/
SELECT dayname, ROUND(AVG(rating),2) Avg_rating FROM salesdata
GROUP BY dayname
ORDER BY Avg_rating DESC
LIMIT 1;

/*28.	Determine the day of the week with the highest average ratings for each branch.*/
WITH Avg_ratings AS (
SELECT branch, dayname, ROUND(AVG(rating),2) Avg_rating  FROM salesdata
GROUP BY branch, dayname
ORDER BY branch),
 Rank_Avg_ratings AS(
SELECT *, RANK() OVER(PARTITION BY branch ORDER BY Avg_rating DESC) rank_rating FROM Avg_ratings)
SELECT branch, dayname, Avg_rating FROM Rank_Avg_ratings
WHERE rank_rating =1;


select branch, sum(total)/(select sum(total) from salesdata)*100 sales from salesdata
group by branch;


select Distinct customer_type from salesdata;






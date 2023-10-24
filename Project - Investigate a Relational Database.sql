--VISUALIZATION SLIDE 1: What is the total Rental Order per Family Friendly Movie Category for all years we have data for. (This is the first question in the Question Set #1)

WITH family_movies AS
	(SELECT f.title movie_title ,
			c.name category ,
			r.rental_id rentals
		FROM film f
		JOIN film_category fc ON f.film_id = fc.film_id
		JOIN category c ON fc.category_id = c.category_id
		JOIN inventory i ON i.film_id = f.film_id
		JOIN rental r ON r.inventory_id = i.inventory_id
		WHERE c.name IN ('Animation' ,
						'Children' ,
						'Classics' ,
						'Comedy' ,
						'Family' ,
						'Music') )
SELECT category,
	count(*) AS rental_count
FROM family_movies
GROUP BY 1
ORDER BY 1;





--VISUALIZATION SLIDE 2: how does the two stores compare in their count of rental orders during every month for all the years we have data for.

SELECT 
	st.store_id, 
	DATE_PART('year', r.rental_date) as rental_year, 
	DATE_PART('month', r.rental_date) as rental_month, 
	COUNT(rental_id) as rental_count
FROM store st
JOIN staff sf
ON st.store_id = sf.store_id
JOIN rental r
ON r.staff_id = sf.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;





--VISUALIZATION SLIDE 3: who were our top 10 paying customers, and what was the amount of their payments made per month


WITH top10 AS (
	SELECT 
		c.customer_id,
		SUM(p.amount) as payment_amount
	FROM customer c
	JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10
	) 

SELECT 
	c.first_name || ' ' || c.last_name as customer_name,
	DATE_TRUNC('month', p.payment_date) as payment_month,
	COUNT(p.payment_date) as payment_count,
	SUM(p.amount) as payment_amount
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
WHERE c.customer_id IN (SELECT customer_id FROM top10)
GROUP BY 1,2
ORDER BY 1,2;





--VISUALIZATION SLIDE 4: For each of the top 10 paying customers, what is the difference accross their monthly payments in 2007

WITH top10 AS (
	SELECT 
		c.customer_id,
		SUM(p.amount) as payment_amount
	FROM customer c
	JOIN payment p
	ON c.customer_id = p.customer_id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10
	), 

top10_details AS (
	SELECT 
		c.first_name || ' ' || c.last_name as customer_name,
		DATE_TRUNC('month', p.payment_date) as payment_month,
		COUNT(p.payment_date) as payment_count,
		SUM(p.amount) as payment_amount
	FROM customer c
	JOIN payment p
	ON c.customer_id = p.customer_id
	WHERE c.customer_id IN (SELECT customer_id FROM top10)
	GROUP BY 1,2
	ORDER BY 1,2
	)

SELECT customer_name,
	payment_month,
	payment_amount,
	LAG(payment_amount) OVER (PARTITION BY customer_name ORDER BY customer_name, payment_month) AS lag,
	payment_amount - LAG(payment_amount) OVER (PARTITION BY customer_name ORDER BY customer_name, payment_month) AS lag_difference
FROM top10_details;

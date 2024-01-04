-- **Rank the customers based on the total amount they've spent on rentals.**
-- ansh 1
select * from customer ; -- first_name , last_name , customer_id 
select * from rental ; -- customerid , inventory id , rental id 
select * from film ;-- film id 

SELECT
     customer.first_name,
    customer.last_name,

    SUM(film.rental_rate) AS total_amount_spent,
    RANK() OVER (ORDER BY SUM(film.rental_rate) DESC) AS customer_rank
FROM
    customer 
JOIN
    rental ON customer.customer_id = rental.customer_id
JOIN
    inventory  ON rental.inventory_id = inventory.inventory_id
JOIN
    film ON inventory.film_id = film.film_id
GROUP BY
    customer.customer_id, customer.first_name, customer.last_name
ORDER BY
    total_amount_spent DESC;
    
    -- que 2 **Calculate the cumulative revenue generated by each film over time.** 
-- ans 
SELECT
    film.title,
    film.rental_rate,
    SUM(film.rental_rate) OVER (PARTITION BY film.film_id ORDER BY rental.rental_date) AS cumulative_revenue
FROM
    film  jOIN inventory  ON film.film_id = inventory.film_id JOIN
    rental  ON inventory.inventory_id = rental.inventory_id
ORDER BY
    film.film_id, rental.rental_date ;
    
    -- que 3 **Determine the average rental duration for each film, considering films with similar lengths.**
    
-- ans 
SELECT
   film_id , title,  rental_duration,
    AVG(rental_duration) OVER (PARTITION BY length) AS avg_rental_duration FROM film
ORDER BY
    film_id;

-- que 4 **Identify the top 3 films in each category based on their rental counts.**

WITH FilmRentalCounts AS (SELECT f.film_id, f.title, c.name AS category, COUNT(*) AS rental_count
    FROM
        film f JOIN film_category fc ON f.film_id = fc.film_id JOIN
        category c ON fc.category_id = c.category_id
    JOIN
        inventory i ON f.film_id = i.film_id JOIN
        rental r ON i.inventory_id = r.inventory_id
    GROUP BY
        f.film_id, f.title, c.name
)
SELECT
    film_id, title, category, rental_count, rank_within_category
FROM (
    SELECT film_id, title, category, rental_count,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY rental_count DESC) AS rank_within_category
    FROM FilmRentalCounts
) RankedFilms WHERE
    rank_within_category <= 3
ORDER BY
    category, rank_within_category;
    
    -- que 5 **Calculate the difference in rental counts between each customer's total rentals and the average rentals across all customers.**
-- ans 

WITH CustomerRentalCounts AS (SELECT c.customer_id,
        COUNT(r.rental_id) AS rental_count,
        AVG(COUNT(r.rental_id)) OVER () AS avg_rental_count
    FROM
        customer c LEFT JOIN
        rental r ON c.customer_id = r.customer_id GROUP BY
        c.customer_id
)
SELECT customer_id, rental_count, rental_count - avg_rental_count AS rental_count_difference
FROM
    CustomerRentalCounts ;
    
    -- que 6 -- **Find the monthly revenue trend for the entire rental store over time.**
    -- ans
    SELECT
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    SUM(rental_rate) OVER (ORDER BY DATE_FORMAT(rental_date, '%Y-%m')) AS monthly_revenue
FROM
    rental
JOIN
    inventory ON rental.inventory_id = inventory.inventory_id
JOIN
    film ON inventory.film_id = film.film_id
ORDER BY
    month;

    
    -- que 8 **Calculate the running total of rentals per category, ordered by rental count.**
-- ams 
WITH CategoryRentalCounts AS (
    SELECT fc.category_id, c.name AS category_name,
        COUNT(r.rental_id) AS rental_count
    FROM
        film_category fc
    JOIN
        film f ON fc.film_id = f.film_id
    JOIN
        inventory i ON f.film_id = i.film_id
    JOIN
        rental r ON i.inventory_id = r.inventory_id
    JOIN
        category c ON fc.category_id = c.category_id
    GROUP BY
        fc.category_id, c.name
)

SELECT
    category_id,category_name,rental_count,SUM(rental_count) OVER (PARTITION BY category_id ORDER BY rental_count DESC) AS running_total
FROM
    CategoryRentalCounts
ORDER BY
    rental_count DESC;
    
    -- que 9 **Find the films that have been rented less than the average rental count for their respective categories.**

WITH FilmRentalCounts AS (
    SELECT fc.film_id,fc.category_id,f.title,COUNT(r.rental_id) AS rental_count,
        AVG(COUNT(r.rental_id)) OVER (PARTITION BY fc.category_id) AS avg_rental_count
    FROM film_category fc
    JOIN
        film f ON fc.film_id = f.film_id
    JOIN
        inventory i ON f.film_id = i.film_id
    JOIN
        rental r ON i.inventory_id = r.inventory_id
    GROUP BY
        fc.film_id, fc.category_id, f.title
)

SELECT
    film_id, category_id, title, rental_count , avg_rental_count
FROM
    FilmRentalCounts
WHERE
    rental_count < avg_rental_count;
    
    -- que 10 **Identify the top 5 months with the highest revenue and display the revenue generated in each month.**
    -- ans 
    
    SELECT month,
    monthly_revenue
FROM ( SELECT DATE_FORMAT(rental_date, '%Y-%m') AS month,
        SUM(rental_rate) AS monthly_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(rental_rate) DESC) AS ranking
    FROM
        rental
    JOIN
        inventory ON rental.inventory_id = inventory.inventory_id
    JOIN
        film ON inventory.film_id = film.film_id
    GROUP BY
        DATE_FORMAT(rental_date, '%Y-%m')
) RankedMonths
WHERE
    ranking <= 5
ORDER BY
    ranking;














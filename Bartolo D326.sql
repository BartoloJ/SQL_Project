/*Provide original code for function(s) in text format that perform the transformation(s) you 
identified in part A4.*/ 
CREATE OR REPLACE FUNCTION ConvertTimestampToDate(ts TIMESTAMP)  
RETURNS DATE AS $$  
BEGIN  
RETURN DATE(ts);  
END;  
$$ LANGUAGE plpgsql; 
  
/*C.  Provide original SQL code in a text format that creates the detailed and summary tables to hold 
your report table sections.*/  
CREATE TABLE Detailed ( 
 Actor_id INT,  
First_name VARCHAR(45),  
Last_name VARCHAR(45),  
Film_id INT, 
Title VARCHAR(255),  
Rental_date DATE,  
Return_date DATE,    
Payment_amount DEC(5,2) 
); 
 
CREATE TABLE Summary ( 
 First_name VARCHAR(45), 
 Last_name VARCHAR(45), 
 Total_revenue DEC(8,2) 
); 
 
  
/*D.  Provide an original SQL query in a text format that will extract the raw data needed for the 
detailed section of your report from the source database.*/  
INSERT INTO Detailed  
SELECT a.actor_id, a.first_name, a.last_name, i.film_id, f.title, 
ConvertTimestampToDate(r.rental_date), ConvertTimestampToDate(r.return_date), 
p.amount 
FROM rental r 
JOIN payment p ON r.rental_id = p.rental_id 
JOIN inventory i ON r.inventory_id = i.inventory_id 
JOIN film f ON i.film_id = f.film_id 
JOIN film_actor fa ON f.film_id = fa.film_id 
JOIN actor a ON fa.actor_id = a.actor_id; 
  
 
 
 
 
/*E.  Provide original SQL code in a text format that creates a trigger on the detailed table of the report 
that will continually update the summary table as data is added to the detailed table.*/  
CREATE OR REPLACE FUNCTION summary_trigger()  
RETURNS TRIGGER AS $$ 
BEGIN  
DELETE FROM summary;  
INSERT INTO summary SELECT first_name, last_name, SUM(payment_amount)  
FROM detailed 
GROUP BY first_name, last_name;  
RETURN NEW;  
END;  
$$ LANGUAGE plpgsql; 
 
CREATE TRIGGER new_summary  
AFTER INSERT 
ON detailed  
FOR EACH STATEMENT 
EXECUTE PROCEDURE summary_trigger();  
  
/*F.  Provide an original stored procedure in a text format that can be used to refresh the data in both 
the detailed table and summary table. The procedure should clear the contents of the detailed table 
and summary table and perform the raw data extraction from part D.*/  
 CREATE OR REPLACE PROCEDURE refresh_tables()  
AS $$ 
BEGIN  
DELETE FROM detailed; 
DELETE FROM summary;  
INSERT INTO Detailed  
SELECT a.actor_id, a.first_name, a.last_name, i.film_id, f.title, 
ConvertTimestampToDate(r.rental_date), ConvertTimestampToDate(r.return_date), 
p.amount 
FROM rental r 
JOIN payment p ON r.rental_id = p.rental_id 
JOIN inventory i ON r.inventory_id = i.inventory_id 
JOIN film f ON i.film_id = f.film_id 
JOIN film_actor fa ON f.film_id = fa.film_id 
JOIN actor a ON fa.actor_id = a.actor_id;  
RETURN;  
END;  
$$ LANGUAGE plpgsql; 
 
CALL refresh_tables(); 
SELECT * FROM detailed; 
SELECT * FROM summary;
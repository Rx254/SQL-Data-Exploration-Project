----View Table-----
SELECT*
FROM IMDB250MoviesIMDB250Moviescsv;

/*Change Table Name*/

ALTER TABLE IMDB250MoviesIMDB250Moviescsv RENAME TO Movies;

SELECT *
From Movies;

------Top 5 Budget Movies------Listing by Order 

SELECT name, budget
From Movies
Order by budget DESC
Limit 5;

/* Update Foreign Currency - Movies*/

Update Movies
SET
budget = replace( budget, 2400000000, 23500000);

update Movies
SET
budget = replace(budget, 550000000, 6640000);

-----Top 5 Rated Movies------

Select name,rating
from Movies
limit 10;

/*Top 5 Box Office Hits*/

Select name, box_office
from Movies
Order by box_office DESC
Limit 5;

-----Top 5 Profitable Movies------Creating New Column

select name, budget, box_office,(box_office-budget) as 'profit'
from Movies
Order by profit desc
limit 5;

------5 Least Profitable Movies-------

select name, budget, box_office,(box_office-budget) as 'profit'
from Movies
Order by profit
limit 5;

/* Most Popular Directors (Group By Fuction)*/

select directors, count(*) as Number
from Movies
group by directors order by Number DESC
limit 10;

-------Most Popular Genres------

Select genre, count(*) as genre_count
from(
  select Trim(value) as genre
  From Movies
  Cross Join json_each('["' || REPLACE(genre, ',','","')|| '"]')
  )
  group by genre
  order by genre_count  desc
  limit 5;
  
  -----Amount of Movies Per Rating-------
  
  SELECT certificate, count(*) as 'Number'
  FROM Movies
  group BY certificate
  order by Number desc;
  
  -----Best Year for Movies-------
  
  SELECT year, count(*) as 'Number'
  FROM Movies
  group BY year
  order by Number desc
  limit 5;
  
  -------Amount of Movies Per 10 Years-----
  
 SELECT
  	year/10*10+1 as decade_start,
    year/10*10+10 As decade_end,
    Count(year) As number_of_movies
 from Movies
 group by year/10
 order by decade_start; 
 
 
 
 WITH genre_counts AS (
  SELECT genre, COUNT(*) AS genre_count, year
  FROM (
    SELECT TRIM(value) AS genre, year
    FROM Movies
    CROSS JOIN json_each('["' || REPLACE(genre, ',', '","') || '"]')
  )
  GROUP BY genre, year
), decade_max_genre AS (
  SELECT d.decade_start, d.decade_end, gc.genre,
         ROW_NUMBER() OVER (PARTITION BY d.decade_start ORDER BY gc.genre_count DESC) AS rn
  FROM (
    SELECT 
      year/10 * 10 + 1 AS decade_start,
      year/10 * 10 + 10 AS decade_end
    FROM Movies
    GROUP BY year/10
  ) d
  JOIN genre_counts gc ON gc.year >= d.decade_start AND gc.year <= d.decade_end
)
SELECT decade_start, decade_end, genre
FROM decade_max_genre
WHERE rn = 1
ORDER BY decade_start
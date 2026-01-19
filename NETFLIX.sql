--create table
DROP TABLE IF EXISTS netflix
CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	releease_year INT,
	rating VARCHAR(10),
	duration VARCHAR(50),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT COUNT(*) AS total_count
FROM netflix 

SELECT DISTINCT type FROM netflix


--15 BUSSINESS PROBLEMS

--COUNT THE NUMBER OF MOVIES VS TV SHOWS
SELECT type,COUNT(*) AS total_counts
FROM netflix
GROUP BY type

--FIND THE MOST COMMON RATING FOR MOVIES AND TV SHOWS
SELECT 
	type,
	rating
FROM(
SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*)DESC) AS ranking
FROM netflix
GROUP BY 1,2
)AS t1
WHERE ranking = 1


--LIST ALL MOVIES RELEASED IN A SPECIFIC YEAR (eg.2020)

SELECT * 
FROM netflix
WHERE type = 'Movie' AND releease_year =2020


--FIND THE TOP 5 COUNRIES WITH THE MOST MOVIES
SELECT 
	UNNEST(STRING_TO_ARRAY(country,','))as new_country,
	COUNT(show_id)AS tota_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


--IDENTIFY THE LONGEST MOVIE
SELECT *
FROM netflix
WHERE 
	type='Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)

--FIND THE CONTENT ADDED IN LAST 5 YEARS
SELECT 
	*
FROM netflix
WHERE 
	TO_DATE(date_added,'Month DD ,YYYY') >= CURRENT_DATE - INTERVAL '5 years'
	
SELECT CURRENT_DATE - INTERVAL '5 years'


--FIND ALL MOVIES / TV SHOWS BY DIRECTOR 'RAJIV CHILAKA'
SELECT * FROM netflix
WHERE director ILIKE  '%Rajiv Chilaka%'


--LIST ALL TV SERIES WHICH HAS MORE THAN 5 SERIES
SELECT 
	*
FROM netflix
WHERE 
	type='TV Show'
	AND
	SPLIT_PART(duration,' ',1) ::numeric > 5

--COUNT THE NUMBER OF CONTENT ITEM IN EACH GENRE

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,','))AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1

--FIND THE EACH YEAR THE AB=VG NUMBER OF CINTENT RELEASED BY INDIA ON NETFLIX IN TOP 5 YEARS
SELECT 
	EXTRACT (YEAR FROM TO_DATE(date_added,'Month DD, YYYY'))AS year,
	COUNT(*),
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India') *100,2) AS AVG_CONTENT_PER_YEAR
FROM netflix
WHERE country = 'India'
GROUP BY 1

--LIST ALL THE DOCUMENTARIES
SELECT * FROM netflix
WHERE
	listed_in ILIKE '%documentaries%'

--FIND ALL CONTENT WITHOUT DIRECTOR

SELECT * FROM netflix
WHERE
	director IS NULL

--MOVIE ACTER = SALMAN KHAN AND APPEARED IN LAST 10 YEARS
SELECT * FROM netflix
WHERE 
	castS ILIKE '%Salman Khan%'
	AND 
	releease_year > EXTRACT(YEAR FROM CURRENT_DATE)-10


--FIND THE TOP 10 ACTORS HIGHESTLY APPEARED IN INDIA
SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
	COUNT(*)AS total_count
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--DESC=KILL, VIOLENCE ->LABLE - BAD OTHERS->GOOD. COUNT HOW MANY FALL INTO EACH CATEGORY

WITH new_table
AS
(
SELECT * ,
	CASE
	WHEN 
	description ILIKE '%kill%'
	OR
	description ILIKE '%violence%'
	THEN 'Bad_Content'
	ELSE 'Good_Content'
	END category
FROM netflix
)
SELECT category,
	COUNT(*)AS total_content
FROM new_table
GROUP BY 1
	
--1. Peak Demand Hours
select extract(HOUR FROM tpep_pickup_datetime) as hour,
count(*) as trips from trips
group by hour
order by trips desc

--2. Top Demand Zones
select pulocationid, count(*) as total_trips from trips
group by pulocationid order by total_trips desc
limit 10

--3. Revenue by Zone
SELECT 
    pulocationid,
    SUM(fare_amount) AS revenue
FROM trips
GROUP BY pulocationid
ORDER BY revenue DESC
LIMIT 10;

--4. Average trip duration
SELECT 
    AVG(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/60) AS avg_duration_min
FROM trips;

--5. Revenue Efficiency
SELECT 
    pulocationid,
    AVG(fare_amount / NULLIF(trip_distance,0)) AS revenue_per_km
FROM trips
GROUP BY pulocationid
ORDER BY revenue_per_km DESC
LIMIT 10;

--6. Congestion(Speed)
SELECT 
    pulocationid,
    AVG(trip_distance / NULLIF(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime))/3600,0)) AS avg_speed
FROM trips
GROUP BY pulocationid
ORDER BY avg_speed ASC;

--7. Surge
WITH demand AS (
    SELECT pulocationid, COUNT(*) AS trips
    FROM trips
    GROUP BY pulocationid
),
revenue AS (
    SELECT pulocationid, SUM(fare_amount) AS revenue
    FROM trips
    GROUP BY pulocationid
)
SELECT 
    d.pulocationid,
    d.trips,
    r.revenue,
    (d.trips * 0.6 + r.revenue * 0.4) AS surge_score
FROM demand d
JOIN revenue r USING (pulocationid)
ORDER BY surge_score DESC
LIMIT 10;
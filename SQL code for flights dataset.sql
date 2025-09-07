--What percentage of flights in experienced a departure delay in 2015? 
--Among those flights, what was the average delay time, in minutes? 



Select
round((count(*) filter (where departure_delay > 0)::numeric)/ count(*) * 100 :: numeric,2)as pct_flights_delayed_departure,
round(avg(arrival_delay) filter (where departure_delay >0),2) as avg_delay_minutes
from flights



--How does the % of delayed flights vary throughout the year? 
--What about for flights leaving from Boston (BOS) specifically? 



Select
month_name,
pct_monthly_delayed_flights,
round(pct_monthly_delayed_flights - lag(pct_monthly_delayed_flights) over(order by month),2) as pct_change_delayed_flight
from 
(Select 
month,
CASE 
    WHEN month = 1  THEN 'January'
    WHEN month = 2  THEN 'February'
    WHEN month = 3  THEN 'March'
    WHEN month = 4  THEN 'April'
    WHEN month = 5  THEN 'May'
    WHEN month = 6  THEN 'June'
    WHEN month = 7  THEN 'July'
    WHEN month = 8  THEN 'August'
    WHEN month = 9  THEN 'September'
    WHEN month = 10 THEN 'October'
    WHEN month = 11 THEN 'November'
    WHEN month = 12 THEN 'December'
END AS month_name,
round(count(*) filter(where departure_delay > 15)::numeric/ count(*) *100,2) as pct_monthly_delayed_flights
from flights
where origin_airport = 'BOS'
group by month_name, month
order by month) as b
order by month


--How many flights were cancelled in 2015? 
--What % of cancellations were due to weather? 
--What % were due to the Airline/Carrier?



Select
sum(cancelled) as total_cancelled_flights, 
round(sum(cancelled) filter (where cancellation_reason = 'B'):: numeric/sum(cancelled) *100,2) as pct_weather_cancelled,
round(sum(cancelled) filter (where cancellation_reason = 'A'):: numeric/sum(cancelled) *100,2) AS PCT_Airline_cancellation
from flights



--Which airlines seem to be most and least reliable, 
--in terms of on-time departure?



Select
CASE 
    WHEN airline = 'AA' THEN 'American Airlines Inc.'
    WHEN airline = 'AS' THEN 'Alaska Airlines Inc.'
    WHEN airline = 'B6' THEN 'JetBlue Airways'
    WHEN airline = 'DL' THEN 'Delta Air Lines Inc.'
    WHEN airline = 'EV' THEN 'Atlantic Southeast Airlines.'
    WHEN airline = 'F9' THEN 'Frontier Airlines Inc.'
    WHEN airline = 'HA' THEN 'Hawaiian Airlines Inc.'
    WHEN airline = 'MQ' THEN 'American Eagle Airlines Inc.'
    WHEN airline = 'NK' THEN 'Spirit Airlines Inc.'
    WHEN airline = 'OO' THEN 'SkyWest Airlines Inc.'
    WHEN airline = 'UA' THEN 'United Air Lines Inc.'
    WHEN airline = 'US' THEN 'US Airways Inc.'
    WHEN airline = 'VX' THEN 'Virgin America'
    WHEN airline = 'WN' THEN 'Southwest Airlines Co.'
    ELSE airline 
END AS airline_name,
round(avg(departure_delay),2) as avg_delay,
round(count(*),0) as number_of_flights
from flights
group by airline
order by avg_delay,number_of_flights DESC



--What was the average arrival delay for each day of the week?
--Does Friday/Sunday (peak travel days) show higher delays?


Select
day_of_week,
round(avg(arrival_delay),2)as avg_arrival_delay
from flights
group by day_of_week
order by avg_arrival_delay DESC



--Which airline had the highest cancellation rate in 2015?
--Express this as % of their total flights.



Select
CASE 
    WHEN airline = 'UA' THEN 'United Air Lines Inc.'
    WHEN airline = 'AA' THEN 'American Airlines Inc.'
    WHEN airline = 'US' THEN 'US Airways Inc.'
    WHEN airline = 'F9' THEN 'Frontier Airlines Inc.'
    WHEN airline = 'B6' THEN 'JetBlue Airways'
    WHEN airline = 'OO' THEN 'Skywest Airlines Inc.'
    WHEN airline = 'AS' THEN 'Alaska Airlines Inc.'
    WHEN airline = 'NK' THEN 'Spirit Air Lines'
    WHEN airline = 'WN' THEN 'Southwest Airlines Co.'
    WHEN airline = 'DL' THEN 'Delta Air Lines Inc.'
    WHEN airline = 'EV' THEN 'Atlantic Southeast Airlines'
    WHEN airline = 'HA' THEN 'Hawaiian Airlines Inc.'
    WHEN airline = 'MQ' THEN 'American Eagle Airlines Inc.'
    WHEN airline = 'VX' THEN 'Virgin America'
    ELSE airline   -- fallback, in case an unknown code appears
END AS airline_name,
round((count(cancellation_reason):: numeric)/count(*) *100,2) as pct_cancelled_flight
from flights
group by airline
order by round((count(cancellation_reason):: numeric)/count(*) *100,2) DESC



--Which origin–destination (OD) airport pairs had the highest average arrival delays?
--Identifies problematic routes.



SELECT
    origin_airport || ' - ' || destination_airport AS route,
    ROUND(AVG(arrival_delay),2) AS avg_arrival_delay,
	count(*) number_of_flights,
	
FROM flights
GROUP BY origin_airport || ' - ' || destination_airport
ORDER BY avg_arrival_delay DESC



--Which airlines improved or worsened the most in on-time 
--performance from January to December 2015?
--Month-over-month airline reliability.



with table1 as (SELECT
  CASE 
    WHEN airline = 'UA' THEN 'United Air Lines Inc.'
    WHEN airline = 'AA' THEN 'American Airlines Inc.'
    WHEN airline = 'US' THEN 'US Airways Inc.'
    WHEN airline = 'F9' THEN 'Frontier Airlines Inc.'
    WHEN airline = 'B6' THEN 'JetBlue Airways'
    WHEN airline = 'OO' THEN 'Skywest Airlines Inc.'
    WHEN airline = 'AS' THEN 'Alaska Airlines Inc.'
    WHEN airline = 'NK' THEN 'Spirit Air Lines'
    WHEN airline = 'WN' THEN 'Southwest Airlines Co.'
    WHEN airline = 'DL' THEN 'Delta Air Lines Inc.'
    WHEN airline = 'EV' THEN 'Atlantic Southeast Airlines'
    WHEN airline = 'HA' THEN 'Hawaiian Airlines Inc.'
    WHEN airline = 'MQ' THEN 'American Eagle Airlines Inc.'
    WHEN airline = 'VX' THEN 'Virgin America'
  END AS airline_name,

  100.0 * (COUNT(CASE WHEN month = 1  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 1  THEN 1 END), 0)  AS January,
  100.0 * (COUNT(CASE WHEN month = 2  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 2  THEN 1 END), 0)  AS February,
  100.0 * (COUNT(CASE WHEN month = 3  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 3  THEN 1 END), 0)  AS March,
  100.0 * (COUNT(CASE WHEN month = 4  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 4  THEN 1 END), 0)  AS April,
  100.0 * (COUNT(CASE WHEN month = 5  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 5  THEN 1 END), 0)  AS May,
  100.0 * (COUNT(CASE WHEN month = 6  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 6  THEN 1 END), 0)  AS June,
  100.0 * (COUNT(CASE WHEN month = 7  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 7  THEN 1 END), 0)  AS July,
  100.0 * (COUNT(CASE WHEN month = 8  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 8  THEN 1 END), 0)  AS August,
  100.0 * (COUNT(CASE WHEN month = 9  THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 9  THEN 1 END), 0)  AS September,
  100.0 * (COUNT(CASE WHEN month = 10 THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 10 THEN 1 END), 0)  AS October,
  100.0 * (COUNT(CASE WHEN month = 11 THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 11 THEN 1 END), 0)  AS November,
  100.0 * (COUNT(CASE WHEN month = 12 THEN departure_delay END) FILTER (WHERE departure_delay < 15))
        / NULLIF(COUNT(CASE WHEN month = 12 THEN 1 END), 0)  AS December

FROM flights
GROUP BY airline)


SELECT
  airline_name,
  ROUND(january, 2) AS january,
  ROUND(february - january, 2)   AS february,
  ROUND(march - february, 2)     AS march,
  ROUND(april - march, 2)        AS april,
  ROUND(may - april, 2)          AS may,
  ROUND(june - may, 2)           AS june,
  ROUND(july - june, 2)          AS july,
  ROUND(august - july, 2)        AS august,
  ROUND(september - august, 2)   AS september,
  ROUND(october - september, 2)  AS october,
  ROUND(november - october, 2)   AS november,
  ROUND(december - november, 2)  AS december
FROM table1;



--What proportion of delays were due to carrier vs weather vs NAS 
--(National Airspace System) issues across all airlines?
--Uses delay cause fields (carrier_delay, weather_delay, nas_delay, etc.).



WITH table1 AS (
    SELECT
      COUNT(*) FILTER (WHERE air_system_delay > 0)     AS air_system_delays,
      COUNT(*) FILTER (WHERE security_delay > 0)       AS security_delays,
      COUNT(*) FILTER (WHERE airline_delay > 0)        AS airline_delays,
      COUNT(*) FILTER (WHERE late_aircraft_delay > 0)  AS late_aircraft_delays,
      COUNT(*) FILTER (WHERE weather_delay > 0)        AS weather_delays
    FROM flights
),
table2 AS (
    SELECT *,
           air_system_delays + 
           security_delays + 
           airline_delays + 
           late_aircraft_delays + 
           weather_delays AS total_delays
    FROM table1
)
SELECT 'Air System' AS delay_type,
       ROUND(air_system_delays / total_delays::NUMERIC * 100, 2) AS pct_delay
FROM table2
UNION ALL
SELECT 'Security',
       ROUND(security_delays / total_delays::NUMERIC * 100, 2)
FROM table2
UNION ALL
SELECT 'Airline',
       ROUND(airline_delays / total_delays::NUMERIC * 100, 2)
FROM table2
UNION ALL
SELECT 'Late Aircraft',
       ROUND(late_aircraft_delays / total_delays::NUMERIC * 100, 2)
FROM table2
UNION ALL
SELECT 'Weather',
       ROUND(weather_delays / total_delays::NUMERIC * 100, 2)
FROM table2;


--Which 10 airports contributed the most to total system-wide minutes of delay in 2015?


with table1 as (Select
origin_airport,
sum(departure_delay) as delay_minutes,
(Select sum(departure_delay) from flights) as total_sum
from flights
group by origin_airport
order by delay_minutes desc 
limit 10)

Select
CASE
    WHEN origin_airport = 'ORD' THEN 'Chicago oHare International'
    WHEN origin_airport = 'ATL' THEN 'Hartsfield–Jackson Atlanta International'
    WHEN origin_airport = 'DFW' THEN 'Dallas/Fort Worth International'
    WHEN origin_airport = 'DEN' THEN 'Denver International'
    WHEN origin_airport = 'LAX' THEN 'Los Angeles International'
    WHEN origin_airport = 'IAH' THEN 'George Bush Intercontinental (Houston)'
    WHEN origin_airport = 'SFO' THEN 'San Francisco International'
    WHEN origin_airport = 'LAS' THEN 'McCarran International (Las Vegas)'
    WHEN origin_airport = 'EWR' THEN 'Newark Liberty International'
    WHEN origin_airport = 'MCO' THEN 'Orlando International'
    ELSE 'Unknown Airport'
END AS origin_airport_name,
ROUND(delay_minutes/total_sum ::NUMERIC *100,2) as pct_of_delay
from table1
order by pct_of_delay DESC


--Total flights per airline


SELECT 
CASE 
    WHEN airline = 'UA' THEN 'United Air Lines Inc.'
    WHEN airline = 'AA' THEN 'American Airlines Inc.'
    WHEN airline = 'US' THEN 'US Airways Inc.'
    WHEN airline = 'F9' THEN 'Frontier Airlines Inc.'
    WHEN airline = 'B6' THEN 'JetBlue Airways'
    WHEN airline = 'OO' THEN 'Skywest Airlines Inc.'
    WHEN airline = 'AS' THEN 'Alaska Airlines Inc.'
    WHEN airline = 'NK' THEN 'Spirit Air Lines'
    WHEN airline = 'WN' THEN 'Southwest Airlines Co.'
    WHEN airline = 'DL' THEN 'Delta Air Lines Inc.'
    WHEN airline = 'EV' THEN 'Atlantic Southeast Airlines'
    WHEN airline = 'HA' THEN 'Hawaiian Airlines Inc.'
    WHEN airline = 'MQ' THEN 'American Eagle Airlines Inc.'
    WHEN airline = 'VX' THEN 'Virgin America'
  END AS airline_name,
count(*) as Total_Flights
from flights
group by airline
order by Total_flights DESC







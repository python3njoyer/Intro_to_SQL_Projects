use BikeStation;

select start_date, end_date from Trips
	where duration < 3600;
    
select name from Stations;

select trip_id from Trips
	where start_date like '2016-06-%'
    or end_date like '2016-06-%';
    
select trip_id from Trips
	where start_date and end_date not like '2016-01-%';
    
select distinct station_id from Status
	where date_time like '2016-01-29%'
    and bikes_available > 0
    and dock_available = 0;
    
select zip from Weather
	where date like '2016-01-%'
    and mean_temperature <= 50;

select trip_id from Trips
	where zip_code in(
    select zip from Weather
	where date like '2016-01-%'
    and mean_temperature <= 50);
    
select station_id from Status
	where date_time > '2016-01-29 06:00:00'
    and date_time < '2016-01-29 09:00:00'
    and bikes_available > 0
    and dock_available = 0;
 
select name from Stations
	where station_id in(
		select station_id from Status
		where date_time > '2016-01-29 06:00:00'
		and date_time < '2016-01-29 09:00:00'
		and bikes_available > 0
		and dock_available = 0);
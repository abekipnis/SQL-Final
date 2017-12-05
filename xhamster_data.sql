#xhamster has 30 million unique visitors per day. porn is the most visited category of website on the internet
#xhamster does not charge to post videos, but content owners with websites can generate revenue from advertisements
use xhamster;

#creating table of individual categories
create table categories as select distinct channels from data where channels not like "%,%" order by channels;

select title, nb_views
	from data
    where nb_views = (select max(nb_views) from data); #shows the most viewed video with title

#number of videos uploaded each year
select year(upload_date), count(*), sum(nb_views), sum(nb_comments) from data 
	where year(upload_date) is not NULL 
    group by year(upload_date) 
    order by year(upload_date);
    
#number of videos uploaded each day of the week
select dayofweek(upload_date), count(*) from data 
	where dayofweek(upload_date) is not NULL 
    group by dayofweek(upload_date) 
    order by dayofweek(upload_date);

#number of uploads by month
select month(upload_date), count(*) from data 
	where month(upload_date) is not NULL 
    group by month(upload_date) 
    order by month(upload_date);

#number of uploads by day of year
select dayofyear(str_TO_DATE(upload_date,'%Y-%d-%m')) as day_of_year, count(*) from data
	where dayofyear(str_TO_DATE(upload_date,'%Y-%d-%m')) is not NULL
	group by dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m'))
    order by dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m'));
    
#channels with the most videos
select data.channels, count(*)
	from data
    inner join categories on data.channels like categories.channels
    group by data.channels
    order by count(*) desc;
#note 4 of the top 5 channels are lgbt related

#channels with the most views
select d.channels, count(*), avg(nb_views)
	from data as d
    inner join categories on d.channels like categories.channels
    group by d.channels
    order by avg(nb_views) desc;

#channels with the longest videos
#4 of the top 5 channels with the longest videos are related to ethnicity/race/country of origin
select d.channels, count(*), avg(runtime/60) as avg_runtime
	from data as d
    inner join categories on d.channels like categories.channels
    group by d.channels
    order by avg(runtime/60) desc;

    #^^^do people like short or long videos better?
    #if this number is big, people like shorter videos better
    #if this number is small, people like longer videos better
select d.channels, count(*), avg(nb_views), 
	avg(nb_comments), 
    avg(nb_comments/nb_views), 
    avg(runtime/60) as avg_runtime, 
    avg(nb_views)/avg(runtime/60) as length_preference
	from data as d
	inner join categories on d.channels like categories.channels
    group by d.channels
    order by avg(nb_views)/avg(runtime/60) desc;
        
#look at number of videos, avg runtime, uploaded per month
select avg(runtime/60), month(upload_date), count(*) from data
	group by month(upload_date)
    order by month(upload_date);
    
#percent of all uploaders that upload more than 20 videos
select (select count(num)
	from (select d.uploader, count(*) as num from data as d
		group by uploader
		having uploader is not null and num>20
		order by count(*) desc) as n)/count(distinct uploader)*100 from data;

#getting averages...
select avg(nb_comments) as avg_num_comments,
	   avg(nb_votes) as avg_num_votes, 
       avg(nb_views) as avg_num_views from data
       group by uploader
       order by avg(nb_views) desc;

#see if people who upload more get videos with more likes/ views/ comments???
select d.uploader, count(*) as num, avg(nb_votes) as avg_votes, 
		avg(nb_comments) as avg_comments,
        avg(nb_views) as avg_views 
        from data as d
		group by uploader
		having uploader is not null
		order by count(*) desc
        limit 10;

#look at specific days of the year
select (case
    when upload_date like '%-14-02' then 'Valentines_Day'
    when upload_date like '%-25-12' then 'Christmas'
    when upload_date like '%-01-01' then 'New Year\'s Day'
    when upload_date like '%-31-12' then 'New Year\'s Eve'
    when upload_date like '%-31-10' then 'Halloween'
    when upload_date like '%-13-05' then 'Mother\'s Day'
    when upload_date like '%-17-06' then 'Father\'s Day'
    when upload_date like '%-4-07' then 'Fourth of July'
    when upload_date like '%-3-17' then 'St Patricks\'s Day'
    when upload_date like '%-11-11' then 'Veteran\'s Day'
    end
    ) as holiday, count(*),
    avg(nb_views)as average_views,
    sum(nb_views)as total_views,
    avg(nb_votes) as average_votes,
    avg(runtime)/60 as average_runtime
    from data
    group by holiday
    order by total_views desc;

#how many videos are uploaded per day of the year?
select count(*), dayofyear(str_to_date(upload_date, '%Y-%d-%m')) as day_of_year
    from data
    group by day_of_year
    order by count(*) desc;

#creating users and granting permissions...
create user 'fab'@'129.133.222.31' identified by 'password';
create user 'sam'@'129.133.206.10' identified by 'password';
grant select on xhamster.data to 'fab'@'129.133.222.31';
grant select on xhamster.categories to 'fab'@'129.133.222.31';
grant select on xhamster.data to 'sam'@'129.133.206.10';
grant select on xhamster.categories to 'sam'@'129.133.206.10';
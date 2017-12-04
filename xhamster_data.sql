select * from data limit 10;
select channels from data limit 10;
select title, nb_views
	from data
    where nb_views = (select max(nb_views) from data); #shows the most viewed video with title

select * from data order by nb_views desc;#shows top 10 most viewed videos
select * from data where channels like "%Amateur%" order by nb_views desc limit 10;

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
    
select upload_date from data limit 10;

create table categories as select distinct channels from data where channels not like "%,%" order by channels;
use xhamster;

select d.channels, count(*), avg(nb_views), 
	avg(nb_comments), 
    avg(nb_comments/nb_views), 
    avg(runtime/60) as avg_runtime, 
    avg(nb_views)/avg(runtime/60) as length_preference
	from data as d
	inner join categories on d.channels like categories.channels
    group by d.channels
    order by avg(nb_views)/avg(runtime/60) desc;
    #^^^do people like short or long videos better?
    #if this number is big, people like shorter videos better
    #if this number is small, people like longer videos better
    
    #order by avg(nb_views) desc, avg(nb_comments) desc;#looking at avg number of views/comments per category
    
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

create user 'fab'@'129.133.222.31' identified by 'password';
grant select on xhamster.data to 'fab'@'129.133.222.31';
grant select on xhamster.categories to 'fab'@'129.133.222.31';
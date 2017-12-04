install.packages("RMySQL")
library(RMySQL)
db=dbConnect(RMySQL::MySQL(), host='127.0.0.1', user='root',password='',dbname='xhamster')
bp=read.csv("Desktop/SQL/xhamster.csv")
tablecreation='create table data(id int(20), upload_date date(), title char(200), channels char(200), description char (100, nb_views int(20), nb_votes int(20), nb_comments int(5), runtime int(10), uploader char(30))'
bp$id=as.numeric(bp$id)
bp$upload_date=as.character.Date(bp$upload_date)
bp$channels=as.character(bp$channels)
bp$nb_views=as.numeric(bp$nb_views)
bp$nb_votes=as.numeric(bp$nb_votes)
bp$nb_comments=as.numeric(bp$nb_comments)
bp$runtime=as.numeric(bp$runtime)
dbWriteTable(db,name="data",row.names=F,overwrite=T,value=bp)

yearuploadsquery='select year(upload_date), count(*), sum(nb_views), sum(nb_comments) from data 
	where year(upload_date) is not NULL 
  group by year(upload_date) 
  order by year(upload_date);'
res1=dbGetQuery(db,yearuploadsquery) 
graphics.off()
#plot number of videos uploaded per year 
plot(res1$year,res$count, type="n")
lines(res1$year,res$count)

#plot total views by upload year
plot(res1$year,res1$'sum(nb_views)', type='n')
lines(res1$year,res1$'sum(nb_views)')  

#plot total comments by upload year
plot(res1$year,res1$'sum(nb_comments)', type='n')
lines(res1$year,res1$'sum(nb_comments)') 

#do users who upload more get more comments/views/votes on average?
uploadsvsviewsq='select d.uploader, count(*) as num, avg(nb_votes) as avg_votes, 
		avg(nb_comments) as avg_comments,
        avg(nb_views) as avg_views 
        from data as d
	    	group by uploader
	     	having uploader is not null
	    	order by count(*) desc
        limit 1000;'
res2=dbGetQuery(db,uploadsvsviewsq) 
graphics.off()
plot(res2$num,res2$avg_votes, type='n')
install.packages("car")
library(car) 
scatterplot(res2$num,res2$avg_votes) 
scatterplot(res2$num,res2$avg_comments)
scatterplot(res2$num,res2$avg_views)


#day of the week uploads
dayq='select dayofweek(upload_date), count(*) from data 
	where dayofweek(upload_date) is not NULL 
  group by dayofweek(upload_date) 
  order by dayofweek(upload_date);'
res3=dbGetQuery(db,dayq)
plot(res3$`dayofweek(upload_date)`,res3$`count(*)`, type='n')
lines(res3$`dayofweek(upload_date)`,res3$`count(*)`) 

#month uploads
monthq='select month(upload_date), count(*) from data 
	where month(upload_date) is not NULL 
  group by month(upload_date) 
  order by month(upload_date);'
res4=dbGetQuery(db,monthq)
plot(res4$`month(upload_date)`, res4$`count(*)`, type='n')
lines(res4$`month(upload_date)`,res4$`count(*)`)

#top posting channels
topchannelsq='select data.channels, count(*)
	from data
  inner join categories on data.channels like categories.channels
  group by data.channels
  order by count(*) desc;'
res5=dbGetQuery(db,topchannelsq)
plot(res5$`count(*)`)


### Checking to see how the number of interactions on a video 
#relates to the video length and the type of description

#length preference (views) by channel
lenprefq='select d.channels,
  avg(nb_views)/avg(runtime/60) as length_preference
  from data as d
  inner join categories on d.channels like categories.channels
  group by d.channels
  order by avg(nb_views)/avg(runtime/60) desc;'
res6=dbGetQuery(db,lenprefq)
plot(res6$length_preference)

#comment preference (views) by channel, sorted by comment preference
comprefq='select d.channels,
  avg(nb_comments)/avg(runtime/60) as comm_preference
  from data as d
  inner join categories on d.channels like categories.channels
  group by d.channels
  order by comm_preference desc;'
res11=dbGetQuery(db,comprefq)
plot(res11$comm_preference)

#comment preference per channel, sorted by length preference per channel 
comprefq2='select d.channels,
  avg(nb_comments)/avg(runtime/60) as comm_preference
  from data as d
  inner join categories on d.channels like categories.channels
  group by d.channels
  order by avg(nb_views)/avg(runtime/60) desc;'
res12=dbGetQuery(db,comprefq)
channels <- 1:94
scatterplot(channels, res12$comm_preference)

#vote preference (views) by channel, sorted by vote preference per channel
voteprefq='select d.channels,
  avg(nb_votes)/avg(runtime/60) as vote_preference
  from data as d
  inner join categories on d.channels like categories.channels
  group by d.channels
  order by vote_preference desc;'
res12=dbGetQuery(db,voteprefq)
plot(res12$vote_preference)

#vote preference (views) by channel, sorted by length preference per channel
voteprefq2='select d.channels,
  avg(nb_votes)/avg(runtime/60) as vote_preference
  from data as d
  inner join categories on d.channels like categories.channels
  group by d.channels
  order by avg(nb_views)/avg(runtime/60) desc;'
res13=dbGetQuery(db,voteprefq2)
scatterplot(channels,res13$vote_preference)

####################################

#avg number of comments by channel
commchannelq='select d.channels, avg(nb_comments) as avg_comments
  from data as d
  inner join categories on d.channels like categories.channels
  group by d.channels
  order by avg(nb_comments) desc'
res7=dbGetQuery(db,commchannelq)
plot(res7$avg_comments)

#avg number of views by channel
viewchannelq='select d.channels, avg(nb_views) as avg_views
  from data as d
  inner join categories on d.channels like categories.channels
  group by d.channels
  order by avg(nb_views) desc'
res8=dbGetQuery(db,viewchannelq)
plot(res8$avg_views)

#############################

#posts by day of year
dayofyearq="select dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m')) as day_of_year, count(*) from data
	where dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m')) is not NULL
  group by dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m'))
  order by dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m'));"
res9=dbGetQuery(db,dayofyearq)
scatterplot(res9$day_of_year,res9$`count(*)`)

#avg runtime by day of year
runtimedayofyearq="select dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m')) as day_of_year, avg(runtime) from data
	where dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m')) is not NULL
  group by dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m'))
  order by dayofyear(str_TO_DATE(upload_date, '%Y-%d-%m'));"
res10=dbGetQuery(db,runtimedayofyearq)
plot(res10$day_of_year,res10$`avg(runtime)`)

##Checking to see if videos uploaded on christmas have more tags related to christmas
descriptionq="select dayofyear(str_to_date(upload_date, '%Y-%d-%m')), count(*) from data
where description like '%christmas%' OR description like '%santa%' OR description like '%elf%' or description like '%jesus%' or description like '%holy%'
group by dayofyear(str_to_date(upload_date, '%Y-%d-%m'));"
res15=dbGetQuery(db,descriptionq)
scatterplot(res15$`dayofyear(str_to_date(upload_date, '%Y-%d-%m'))`, res15$`count(*)`)

#videos posted about mothers go down around mother's day
mothersdayq="select dayofyear(str_to_date(upload_date, '%Y-%d-%m')), count(*) from data
where channels LIKE '%MILF%' OR description LIKE '%milf%' or description like '%mother%' or description like '%mom%' or description like '%mommy%'
or description like '%mama%'
group by dayofyear(str_to_date(upload_date, '%Y-%d-%m'));"
res16=dbGetQuery(db,mothersdayq)
scatterplot(res16$`dayofyear(str_to_date(upload_date, '%Y-%d-%m'))`, res16$`count(*)`)

#do people upload more videos about celebrities around the time of awards shows???
celebq="select dayofyear(str_to_date(upload_date, '%Y-%d-%m')), count(*) from data
where channels LIKE '%moviestar%' OR description LIKE '%celeb%' or description like '%star%' or description like '%famous%'
group by dayofyear(str_to_date(upload_date, '%Y-%d-%m'));"
res18=dbGetQuery(db,celebq)
scatterplot(res18$`dayofyear(str_to_date(upload_date, '%Y-%d-%m'))`, res18$`count(*)`)

#do people upload more videos with halloween related tags around halloween?
halloweenq="select month(str_to_date(upload_date, '%Y-%d-%m')), count(*) from data
where description like '%vampire%' 
OR description like '%dracula%' 
OR description like '%blood%' 
OR description like '%ghost%' 
OR description like '%spooky%' 
OR description like '%mummy%' 
OR description like '%trick%or%treat%' 
OR description like '%scary%'
group by month(str_to_date(upload_date, '%Y-%d-%m'));"
res19=dbGetQuery(db,halloweenq)
scatterplot(res19$`month(str_to_date(upload_date, '%Y-%d-%m'))`, res19$`count(*)`)

install.packages("RMySQL")
library(RMySQL)
db=dbConnect(RMySQL::MySQL(), host='127.0.0.1', user='root',password='',dbname='xhamster')
q='use xhamster'
bp=read.csv("Desktop/SQL/xhamster.csv")
res=dbGetQuery(db,q) 
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

select location, sum(impressions) as totalimpressions
from campaigndata
group by location
order by sum(impressions) desc 
limit 3;
select target_audience, avg(engagement_score) as avgengagementscore
from campaigndata
group by target_audience
order by avgengagementscore desc;

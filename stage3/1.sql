select campaign_id, sum(impressions) AS totalimpressions
from campaigndata
group by campaign_id
ORDER BY totalimpressions DESC;


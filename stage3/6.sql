SELECT 
    campaign_id,
    company,
    (acquisition_cost::NUMERIC / conversion_rate) AS costperconversion
	FROM campaigndata
ORDER BY costperconversion asc
LIMIT 1;





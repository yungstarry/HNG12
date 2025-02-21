SELECT campaign_id, company, ROUND((clicks * 100.0 / impressions), 4) AS ctr
FROM campaigndata
WHERE ROUND((clicks * 100.0 / impressions), 2) > 5.0
  ORDER BY ctr DESC;
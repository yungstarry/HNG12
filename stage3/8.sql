SELECT channel_used, SUM(conversion_rate) AS totalconversions
FROM campaigndata
GROUP BY channel_used
ORDER BY totalconversions DESC;

# Advanced Outlier Detection Report

## Methodology

This analysis employs a multi-faceted approach to detect outliers in the 2023 election data for Osun State, combining geospatial clustering, statistical methods, machine learning validation, and demographic integration. Each method contributes to a composite outlier score, which is used to identify polling units with anomalous voting patterns. Below is a detailed explanation of each methodology.

### 1. Geospatial Clustering with DBSCAN

**Purpose**: To identify spatial clusters of polling units and detect outliers that do not belong to any cluster, which may indicate isolated anomalies in voting patterns.

**Method**: We used the Density-Based Spatial Clustering of Applications with Noise (DBSCAN) algorithm, which groups polling units based on their geographic proximity. DBSCAN requires two parameters:
- **Epsilon (eps)**: The maximum distance between two polling units to be considered part of the same cluster. We tested three radii: 500m, 1000m, and 2000m, to explore clustering at different scales.
- **Minimum Points (min_samples)**: The minimum number of polling units required to form a cluster. We set this to 5, ensuring clusters are meaningful.

**Implementation**:
- Polling unit coordinates (`Latitude`, `Longitude`) were used to compute pairwise distances using the Haversine formula, which accounts for the Earth's curvature.
- DBSCAN was applied at each radius, labeling polling units as either part of a cluster or as outliers (noise points).
- Results showed that at a 500m radius, 41.24% of polling units were outliers, decreasing to 12.46% at 2000m, indicating that smaller radii are more sensitive to isolated polling units.

**Rationale**: DBSCAN was chosen because it does not require specifying the number of clusters in advance (unlike K-means) and can identify outliers naturally. The varying radii allowed us to assess the robustness of clustering and outlier detection across different spatial scales.

### 2. Statistical Methods: Local Moran's I and Getis-Ord Gi*

**Purpose**: To detect spatial autocorrelation and identify hot spots (high vote concentrations) and cold spots (low vote concentrations) in voting patterns for each party (APC, PDP, LP, NNPP).

**Methods**:
- **Local Moran's I**: Measures spatial autocorrelation for each polling unit, identifying whether a polling unit's vote count for a party is similar to or different from its neighbors. A negative Local Moran's I value with a p-value < 0.05 indicates a spatial outlier (e.g., a polling unit with high votes surrounded by low-vote neighbors).
- **Getis-Ord Gi***: Identifies hot spots (clusters of high vote counts) and cold spots (clusters of low vote counts). A positive Gi* value with a p-value < 0.05 indicates a hot spot, while a negative value indicates a cold spot.

**Implementation**:
- A spatial weights matrix was created using the k-nearest neighbors (k=5) approach, where each polling unit is connected to its 5 nearest neighbors based on geographic distance.
- Local Moran's I and Getis-Ord Gi* were calculated for each party's votes (APC, PDP, LP, NNPP) using the `esda` library in Python.
- Polling units were flagged as significant if their p-values were < 0.05, indicating statistically significant spatial patterns.

**Rationale**: These methods were chosen because they provide complementary insights into spatial patterns. Local Moran's I detects individual polling units that deviate from their neighbors, while Getis-Ord Gi* identifies broader clusters of high or low voting activity, which may indicate coordinated anomalies.

### 3. Machine Learning Validation with Isolation Forest

**Purpose**: To detect anomalies in voting patterns using a machine learning approach, focusing on vote counts and voter turnout metrics.

**Method**: Isolation Forest is an unsupervised anomaly detection algorithm that isolates observations by randomly selecting features and splitting values. Anomalies are identified as observations that require fewer splits to isolate.

**Implementation**:
- Features used: Each party's votes (e.g., `APC`, `PDP`, `LP`, `NNPP`), `Accredited_Voters`, and `Registered_Voters`.
- The Isolation Forest algorithm was applied with a contamination parameter of 0.1, meaning we expect 10% of polling units to be outliers.
- Polling units were flagged as outliers if their Isolation Forest score was -1.

**Rationale**: Isolation Forest was chosen because it is effective for high-dimensional data and does not assume a specific distribution for the data. Including `Accredited_Voters` and `Registered_Voters` alongside vote counts allowed us to detect anomalies in turnout as well as voting patterns, providing a more comprehensive outlier detection.

### 4. Demographic Integration

**Purpose**: To contextualize voting patterns and outliers by integrating socio-economic and demographic data, which may explain anomalies.

**Implementation**:
- State-level socio-economic data for Osun State was sourced, including poverty rate (%), literacy rate (%), urbanization rate (%), and youth population (%).
- This data was merged with historical election data (2015, 2019, 2023) to create a combined dataset (`combined_data_with_socio`).
- The demographic data was used to analyze historical trends and correlate voting patterns with socio-economic factors. For example, the rise in LP votes in 2023 was correlated with a high youth population, as LP's candidate, Peter Obi, had strong youth appeal.

**Rationale**: Demographic integration provides a deeper understanding of voting behavior. For instance, high poverty rates might correlate with voter apathy (low turnout), while a high youth population might explain increased support for LP in 2023.

### 5. Composite Outlier Score Calculation

**Purpose**: To combine the results of the above methods into a single metric for identifying significant outliers.

**Implementation**:
- For each party (APC, PDP, LP, NNPP), a party-specific outlier score was calculated by summing binary indicators from each method:
  - Local Moran's I: 1 if the polling unit is a significant spatial outlier (p < 0.05 and negative Moran's I), 0 otherwise.
  - Getis-Ord Gi*: 1 if the polling unit is a significant hot spot or cold spot (p < 0.05), 0 otherwise.
  - Isolation Forest: 1 if the polling unit is flagged as an outlier, 0 otherwise.
- The party-specific outlier score (e.g., `APC_Outlier_Score`) ranges from 0 to 3, with higher scores indicating more significant outliers.
- A general `Outlier_Score` was also calculated using the same approach but applied to a combined set of features (PDP, APC, Accredited_Voters, Registered_Voters).

**Rationale**: The composite score ensures that polling units flagged by multiple methods are prioritized, increasing confidence in the outlier detection. Party-specific scores allow us to identify anomalies specific to each party's voting patterns.




## Identification and Justification of Top 5 Outlier Polling Units

The following polling units were identified as the top 5 outliers based on their composite `Outlier_Score`, which ranges from 0 to 3 and is calculated by combining results from Local Moran's I, Getis-Ord Gi*, and Isolation Forest. A polling unit is considered a significant outlier if it is flagged by at least two methods (i.e., `Outlier_Score` >= 2). We further filtered for polling units with significant Local Moran's I (p < 0.05) to ensure spatial relevance and sorted by `Outlier_Score` in descending order.

### 1. Polling Unit: HOLY SAVIOUR'S PRY. SCHOOL, OKE TUBU (Ife East LGA, Modakeke II Ward)
- **PU-Code**: 29-13-09-004
- **Votes**: APC: 279, PDP: 120, LP: 31, NNPP: 0
- **Outlier Metrics**:
  - `Outlier_Score`: 3 (flagged by all three methods).
  - Local Moran's I: -0.424342 (p < 0.05), indicating a significant spatial outlier. The negative value suggests this polling unit's voting pattern differs from its neighbors (e.g., high APC votes in an area with lower APC support).
  - Getis-Ord Gi*: 0.228936 (p < 0.05), indicating a hot spot of voting activity, likely due to the high APC vote count.
  - Isolation Forest: -1 (outlier), likely due to the unusually high APC votes (279) compared to the state average.
- **Voting Patterns**:
  - Total votes: 279 + 120 + 31 = 430.
  - APC: 279 votes (64.9% of total votes in this polling unit), significantly higher than the state average of 48.03% for APC in 2023.
  - PDP: 120 votes (27.9%), lower than the state average of 48.47%.
  - LP: 31 votes (7.2%), higher than the state average of 3.29%, indicating notable support for LP.
- **Justification**: This polling unit is a significant outlier due to its high APC vote count, which deviates from both its spatial neighbors (negative Local Moran's I) and the state average. The hot spot (Getis-Ord Gi*) suggests localized high voting activity, and the Isolation Forest flag indicates an anomaly in the vote distribution. The above-average LP votes also suggest a shift in voter preference, possibly due to demographic factors.

### 2. Polling Unit: ODE-OKE (Ede South LGA, Alajue I Ward)
- **PU-Code**: 29-08-04-006
- **Votes**: APC: 113, PDP: 0, LP: 3, NNPP: 207
- **Outlier Metrics**:
  - `Outlier_Score`: 3 (flagged by all three methods).
  - Local Moran's I: -0.037318 (p < 0.05), indicating a spatial outlier. The negative value suggests this polling unit's voting pattern differs from its neighbors.
  - Getis-Ord Gi*: -0.025296 (p < 0.05), indicating a cold spot, likely due to the absence of PDP votes.
  - Isolation Forest: -1 (outlier), likely due to the unusually high NNPP votes (207) and zero PDP votes.
- **Voting Patterns**:
  - Total votes: 113 + 0 + 3 + 207 = 323.
  - APC: 113 votes (35.0%), below the state average of 48.03%.
  - PDP: 0 votes (0%), significantly below the state average of 48.47%.
  - NNPP: 207 votes (64.1%), drastically higher than the state average of 0.21%.
- **Justification**: This polling unit stands out due to its complete lack of PDP votes and an unusually high NNPP vote count, which is highly anomalous given NNPP's minimal presence in Osun State (0.21% state average). The spatial outlier status (Local Moran's I) and cold spot (Getis-Ord Gi*) suggest this polling unit deviates from its neighbors, and the Isolation Forest flag confirms the anomaly in vote distribution.

### 3. Polling Unit: BABA ODUNAYO (Irepodun LGA, Bara 'B' Ward)
- **PU-Code**: 29-20-06-008
- **Votes**: APC: 0, PDP: 0, LP: 0, NNPP: 0
- **Outlier Metrics**:
  - `Outlier_Score`: 3 (flagged by all three methods).
  - Local Moran's I: 0.001931 (p < 0.05), indicating a spatial outlier.
  - Getis-Ord Gi*: 0.165712 (p < 0.05), indicating a hot spot, though this may be an artifact of zero votes in a region with some voting activity.
  - Isolation Forest: -1 (outlier), due to zero votes across all parties.
- **Voting Patterns**:
  - Total votes: 0.
  - All parties: 0 votes, compared to state averages (APC: 48.03%, PDP: 48.47%, LP: 3.29%, NNPP: 0.21%).
- **Justification**: This polling unit is an outlier due to its complete lack of votes, which is highly unusual in an election context. The spatial outlier status (Local Moran's I) indicates it differs from its neighbors, which likely recorded some votes. The Isolation Forest flag confirms the anomaly, as zero votes across all parties is a significant deviation from expected voting patterns.

### 4. Polling Unit: OPEN SPACE INFRONT OF OSUN STATE GOVT. REVENUE... (Atakumosa East LGA, Iwara Ward)
- **PU-Code**: 29-01-01-009
- **Votes**: APC: 17, PDP: 34, LP: 0, NNPP: 0
- **Outlier Metrics**:
  - `Outlier_Score`: 3 (flagged by all three methods).
  - Local Moran's I: 0.364130 (p < 0.05), indicating a spatial outlier.
  - Getis-Ord Gi*: 0.342869 (p < 0.05), indicating a hot spot.
  - Isolation Forest: -1 (outlier), likely due to low total votes.
- **Voting Patterns**:
  - Total votes: 17 + 34 = 51.
  - APC: 17 votes (33.3%), below the state average of 48.03%.
  - PDP: 34 votes (66.7%), above the state average of 48.47%.
- **Justification**: This polling unit is an outlier due to its low total votes (51) and a higher-than-average PDP vote share. The spatial outlier status (Local Moran's I) and hot spot (Getis-Ord Gi*) suggest it differs from its neighbors, possibly indicating a small, localized voting pattern. The Isolation Forest flag confirms the anomaly in the low vote count.

### 5. Polling Unit: OPEN SPACE OLOSUN COMP. EDE (Ede North LGA, Asunmo Ward)
- **PU-Code**: 29-07-10-003
- **Votes**: APC: 108, PDP: 0, LP: 6, NNPP: 0
- **Outlier Metrics**:
  - `Outlier_Score`: 3 (flagged by all three methods).
  - Local Moran's I: 0.199370 (p < 0.05), indicating a spatial outlier.
  - Getis-Ord Gi*: 0.170041 (p < 0.05), indicating a hot spot.
  - Isolation Forest: -1 (outlier), likely due to zero PDP votes.
- **Voting Patterns**:
  - Total votes: 108 + 0 + 6 = 114.
  - APC: 108 votes (94.7%), significantly higher than the state average of 48.03%.
  - PDP: 0 votes (0%), significantly below the state average of 48.47%.
  - LP: 6 votes (5.3%), above the state average of 3.29%.
- **Justification**: This polling unit is an outlier due to its extremely high APC vote share and complete lack of PDP votes. The spatial outlier status (Local Moran's I) and hot spot (Getis-Ord Gi*) suggest a localized anomaly, and the Isolation Forest flag confirms the unusual vote distribution.



## Historical Comparisons for Top 5 Outlier Polling Units

Since polling unit-level historical data for 2015 and 2019 is unavailable, we compare the 2023 voting patterns of the top 5 outliers to state-level historical trends for Osun State. The state-level vote shares are as follows:
- 2015: APC: 59.69%, PDP: 38.89%, LP: 0%, NNPP: 0%
- 2019: APC: 48.64%, PDP: 47.21%, LP: 0%, NNPP: 0%
- 2023: APC: 48.03%, PDP: 48.47%, LP: 3.29%, NNPP: 0.21%

### 1. HOLY SAVIOUR'S PRY. SCHOOL, OKE TUBU
- **2023 Votes**: APC: 279 (64.9%), PDP: 120 (27.9%), LP: 31 (7.2%), NNPP: 0 (0%).
- **Comparison**:
  - APC: 64.9% is higher than the 2023 state average (48.03%) and the 2015 peak (59.69%), suggesting unusually strong APC support.
  - PDP: 27.9% is below the 2023 state average (48.47%) and the 2019 peak (47.21%), indicating a decline in PDP support.
  - LP: 7.2% is significantly higher than the 2023 state average (3.29%) and the 0% in 2015/2019, reflecting LP's national rise in 2023.
  - NNPP: 0% aligns with its minimal historical presence.

### 2. ODE-OKE
- **2023 Votes**: APC: 113 (35.0%), PDP: 0 (0%), LP: 3 (0.9%), NNPP: 207 (64.1%).
- **Comparison**:
  - APC: 35.0% is below the 2023 state average (48.03%) and historical averages, indicating weaker APC support.
  - PDP: 0% is drastically below the 2023 state average (48.47%) and historical averages, suggesting a complete loss of PDP support.
  - LP: 0.9% is below the 2023 state average (3.29%), showing minimal LP presence.
  - NNPP: 64.1% is an extreme outlier compared to the 2023 state average (0.21%) and 0% in 2015/2019, indicating a significant anomaly.

### 3. BABA ODUNAYO
- **2023 Votes**: APC: 0 (0%), PDP: 0 (0%), LP: 0 (0%), NNPP: 0 (0%).
- **Comparison**:
  - All parties: 0% votes compared to state averages (APC: 48.03%, PDP: 48.47%, LP: 3.29%, NNPP: 0.21%) and historical trends, indicating a complete lack of voting activity, which is highly unusual.

### 4. OPEN SPACE INFRONT OF OSUN STATE GOVT. REVENUE...
- **2023 Votes**: APC: 17 (33.3%), PDP: 34 (66.7%), LP: 0 (0%), NNPP: 0 (0%).
- **Comparison**:
  - APC: 33.3% is below the 2023 state average (48.03%) and historical averages, showing weaker APC support.
  - PDP: 66.7% is higher than the 2023 state average (48.47%) and historical averages, indicating strong PDP support.
  - LP and NNPP: 0% aligns with their minimal historical presence in 2015/2019, though LP's 2023 state average (3.29%) suggests missed opportunity.

### 5. OPEN SPACE OLOSUN COMP. EDE
- **2023 Votes**: APC: 108 (94.7%), PDP: 0 (0%), LP: 6 (5.3%), NNPP: 0 (0%).
- **Comparison**:
  - APC: 94.7% is significantly higher than the 2023 state average (48.03%) and the 2015 peak (59.69%), indicating an extreme concentration of APC support.
  - PDP: 0% is well below the 2023 state average (48.47%) and historical averages, showing a complete absence of PDP votes.
  - LP: 5.3% is above the 2023 state average (3.29%), reflecting LP's rise.
  - NNPP: 0% aligns with its minimal historical presence.


  ## Hypotheses on Potential Reasons for Anomalies

### 1. HOLY SAVIOUR'S PRY. SCHOOL, OKE TUBU
- **Anomaly**: High APC votes (64.9%) and above-average LP votes (7.2%).
- **Hypothesis**:
  - The high APC vote share may indicate strong local loyalty to APC, possibly due to historical party dominance in Ife East LGA or influence from local leaders.
  - The above-average LP votes could be driven by a high youth population (42.3% in Osun State), as LP's candidate, Peter Obi, had strong appeal among younger voters in 2023.
  - The polling unit's location in Modakeke II, a potentially urbanized area (state urbanization rate: 47.8%), may have facilitated better voter mobilization for both APC and LP.

### 2. ODE-OKE
- **Anomaly**: Zero PDP votes and extremely high NNPP votes (64.1%).
- **Hypothesis**:
  - The complete absence of PDP votes suggests possible voter suppression, intimidation, or logistical issues (e.g., PDP agents not present at the polling unit).
  - The high NNPP votes are highly unusual given NNPP's minimal presence in Osun State (0.21% state average). This could indicate vote inflation or manipulation, possibly due to low oversight in Ede South LGA.
  - The high poverty rate (26.1%) in Osun State might have made voters in this area more susceptible to vote-buying, potentially benefiting NNPP.

### 3. BABA ODUNAYO
- **Anomaly**: Zero votes for all parties.
- **Hypothesis**:
  - The complete lack of votes likely indicates logistical failures, such as the polling unit not opening on election day, missing ballot materials, or voter intimidation preventing turnout.
  - Irepodun LGA may have faced accessibility issues, especially if this polling unit is in a rural area (state urbanization rate: 47.8%, suggesting over half the state is rural).
  - The high poverty rate (26.1%) and moderate literacy rate (67.5%) might have contributed to voter apathy, though this doesn’t fully explain zero turnout.

### 4. OPEN SPACE INFRONT OF OSUN STATE GOVT. REVENUE...
- **Anomaly**: Low total votes (51) and high PDP vote share (66.7%).
- **Hypothesis**:
  - The low total votes suggest low turnout, possibly due to voter apathy, logistical issues, or a small voter population in this polling unit.
  - The high PDP vote share may reflect historical PDP loyalty in Atakumosa East LGA, as PDP had a strong presence in Osun State in 2015 (38.89%) and 2019 (47.21%).
  - The moderate literacy rate (67.5%) might have limited voter awareness or engagement, contributing to the low turnout.

### 5. OPEN SPACE OLOSUN COMP. EDE
- **Anomaly**: Extremely high APC vote share (94.7%) and zero PDP votes.
- **Hypothesis**:
  - The high APC vote share suggests potential vote inflation or manipulation, as it far exceeds the state average (48.03%) and historical peaks (59.69% in 2015).
  - The absence of PDP votes could indicate voter suppression or intimidation, preventing PDP supporters from voting.
  - Ede North LGA may have strong APC influence, possibly due to local political dynamics or party agents exerting control at this polling unit.

## Recommendations for Election Authorities

Based on the analysis of the top 5 outlier polling units, the following recommendations are proposed for election authorities to improve the integrity and fairness of future elections in Osun State:

1. **Investigate Polling Units with Extreme Vote Distributions**:
   - Conduct a thorough investigation into polling units like ODE-OKE (high NNPP votes, zero PDP votes) and OPEN SPACE OLOSUN COMP. EDE (94.7% APC votes, zero PDP votes) for potential vote inflation, manipulation, or voter suppression.
   - Deploy independent observers to these polling units in future elections to ensure transparency.

2. **Address Logistical Failures**:
   - Investigate the reasons for zero turnout at BABA ODUNAYO and similar polling units. Ensure that all polling units are operational on election day, with adequate ballot materials and security.
   - Improve accessibility in rural areas (e.g., Irepodun LGA) by providing transportation or mobile voting units, especially given the state’s urbanization rate (47.8%).

3. **Enhance Voter Education and Engagement**:
   - Increase voter education campaigns in areas with low turnout, such as OPEN SPACE INFRONT OF OSUN STATE GOVT. REVENUE..., to combat voter apathy. Focus on areas with moderate literacy rates (67.5%) to ensure voters understand the process.
   - Target youth populations (42.3% in Osun State) with campaigns to sustain their engagement, as seen with LP’s rise in areas like HOLY SAVIOUR'S PRY. SCHOOL, OKE TUBU.

4. **Monitor Areas with Emerging Party Support**:
   - Monitor polling units with high LP votes (e.g., HOLY SAVIOUR'S PRY. SCHOOL, OKE TUBU) in future elections, as LP’s rise in 2023 indicates shifting voter preferences, particularly among the youth.
   - Ensure balanced representation of party agents at these polling units to prevent dominance by any single party.

5. **Combat Socio-Economic Vulnerabilities**:
   - Address the high poverty rate (26.1%) in Osun State, which may make voters susceptible to vote-buying (e.g., potentially in ODE-OKE). Implement stricter monitoring of financial transactions around polling units on election day.
   - Provide economic support programs to reduce poverty, which could decrease voter apathy and improve turnout.


   ## Interactive Dashboard

The interactive visualization dashboard is available at the following link:

[Osun State 2023 Election Outlier Analysis Dashboard](<insert-your-power-bi-link-here>)

Stakeholders can explore the dashboard to view:
- A map of polling units with the top 5 outliers highlighted.
- Bar charts comparing vote shares of the top 5 outliers to state averages.
- Historical trends of vote shares from 2015 to 2023.
- Spatial clusters and hot/cold spots.
- Detailed tables of outlier polling units.


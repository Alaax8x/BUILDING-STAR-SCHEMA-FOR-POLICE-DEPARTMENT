In this report, we are going to build two Star Schema (SS) to address the data coming from a police department. Version 1 will more sophisticated one which will be addressing the issue of rape and serious sexual offences (RASSO). Version 2 will be simpler SS and will take it further to the coding stage and will implement some Extract Transform Load (ETL). The data is about the crimes that took place in different parts of the UK. Data like when the crime was reported, the type of crime, status of the crime and location. As well as records of different stations and employees. However, in version 2 we are going to be focusing our star schema on a specific KPI. The KPI chosen for this star schema is to identify areas with crime hotspots. 

The three reports that this SS supports:

•	Number of crimes per station per year

•	Top three stations with the highest number of crimes

•	Number of closed crimes in each station

We have chosen two dimensions for our SS, time and station. For time, it will be necessary to have a line dimension that is going to explain how frequently crimes are happening in registered station. Station dimension will answer the question of where, so our SS is answering the questions of where and when. This is a helpful SS because it is going to give the decision makers an idea of where there is a station with high number of crimes happening at, so they give more resources to the station in order to minimise the number of crimes. For the granularity, due to the computing power we have, we tried to make it as simple as possible. Otherwise, having for example the day as the lowest granularity will help tremendously in identifying which days has the highest reported crimes which could be for instance on weekends and that tell us something about the situation.

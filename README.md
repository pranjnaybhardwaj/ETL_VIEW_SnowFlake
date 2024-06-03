The following is a sample ETL (Extract, Transform, Load) code in SQL, designed to transform raw data from Snowflake tables replicated from SAP. This example demonstrates the type of ETL pipelines I have developed, with over 30 such pipelines implemented on the Snowflake Cloud Data Warehouse
+-----------------+       +-----+       +----------+       +--------------+       +-------+       +----------+
|   SAP System    | ----> | HVR | ----> | Snowflake | ----> | Transformation | ----> | Views | ----> | Tableau  |
| (Source System) |       |     |       |          |       |              |       |       |       | Dashboards |
+-----------------+       +-----+       +----------+       +--------------+       +-------+       +----------+

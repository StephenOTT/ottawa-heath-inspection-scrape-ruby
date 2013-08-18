[![Code Climate](https://codeclimate.com/github/StephenOTT/ottawa-heath-inspection-scrape-ruby.png)](https://codeclimate.com/github/StephenOTT/ottawa-heath-inspection-scrape-ruby)

ottawa-heath-inspection-scrape-ruby
===================================

Downloading of Ottawa Health Inspection Data with Ruby into MongoDB database

----


1. Install MongoDB and start default mongodb setup
2. Run Ruby script

All data will download into mongodb database.  Each company.restaurant is a single object in mongo.  Any inspections are sub-documents in Mongo.

## TODO

- [x] Convert Date/Times to a proper format for Mongo - Refer to Github-Analytics Convert DateTime methods for code for conversion for mongo (Completed)


## Notes:

1. Duration of downloading all data from Health inspection website is about 2 hours.  This is because each webpage must be downloaded individually.
2. All data is downloaded into the Mongodb database
3. 


## Downloads
1. Aug 17 - 5445 Records were downloaded in 7303.2 seconds - According to count on Health Inspections report website there is are a total of 5453 records.  Need to investigate the missing records
2. Aug 17 - 5453 Records were downloaded in 7213.8 seconds - Count Matches Website Count value

-----

## Types of Analysis to Produce

1. Breakdown of Restaurant Names and the Count for that Name
2. ID formatting and spelling mistakes in Restaurant Names
3. Recently Failed Restaurant Inspections
4. GIS locations of Restaurants
5. Breakdown of Resturant Categories
6. Breakdown of Resturant Categories and Failed Inspections
7. Breakdown of Restaurants in City Sectors
8. Failed inspections per neighbourhood
9. Failed inspections per Ward
10. Number of inspections Per Month
11. Number of Inspections Per Month Per Restaurant Type
12. Number of Inspections Per Quarter
13. Number of Inspections Per Ward
14. Breakdown of Inspection Times
15. Breakdown of Inspection Times and Restaurant Categories
16. Most Inspected Restaurants
17. Least Inspected Restaurants
18. Most Inspected Resturants Per Category
19. Least Inspected Resturants Per Cateogry
20. Restaurant Inspections Count Per Cateogry Broken down by Month, Quarter and Week.
21. Analysis of Record Creation / Restaurant Creation
22. General Count of Resturant Inspection Failures Per Restaurant
23. Restaurant Inspection Failures per restaurant per week, month and quarter
24. Analyst of Inspections and Pass/Fail of Food Cart/Truck Vendors
25. Phone Number Analysis (Area Codes)
26. Shared Phone Numbers Analysis
27. Street Analysis - Breakdown of restaurants per street with failures
28. Analysis count of restaurants that have no inspections
29. Analysis count of restaurants that are marked as "Closed" (example from old Drupal repo: https://github.com/StephenOTT/OttawaHealthInspectionsScrape/issues/5)

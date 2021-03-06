[![Code Climate](https://codeclimate.com/github/StephenOTT/ottawa-heath-inspection-scrape-ruby.png)](https://codeclimate.com/github/StephenOTT/ottawa-heath-inspection-scrape-ruby)

ottawa-heath-inspection-scrape-ruby
===================================

Downloading of Ottawa Health Inspection Data with Ruby into MongoDB database

----


1. Install MongoDB and start default mongodb setup (http://docs.mongodb.org/manual/installation/)
2. Run Ruby script

All data will download into mongodb database.  Each company.restaurant is a single object in mongo.  Any inspections are sub-documents in Mongo.

## TODO

- [x] ~~Convert Date/Times to a proper format for Mongo - Refer to Github-Analytics Convert DateTime methods for code for conversion for mongo (Completed)~~
- [ ] Add suport for multilingual (En/Fr) Analysis class responses
- [ ] Convert into Sinatra App
- [ ] Rebuild Analysis/Aggregation code for new usage of Nokogiri
- [ ] Split .rd file into separate files (download, analyze, Sinatra stuff, etc)
- [ ] Provide JSON output option to use as API
- [ ] Provide Query/Search feature (Input Restaurant ID, and Output Restaurant details and inspections) - Used for API-Like functionality that does not require DB for storage.  A list API would provide listing of restaurants/facilities with a ID value which is used to query the Health inspection site.  Returned values would be in JSON structure.



~~NOTE: Sept 2: Major refactor coming in next few days that better reformats data into Mongo~~  Refactor has occured for use of xpath and customized output for mongo.  See image/screenshot below for sample. (Sept 5)



## Notes:

1. Duration of downloading all data from Health inspection website is about 2 hours.  This is because each webpage must be downloaded individually.
2. All data is downloaded into the Mongodb database
3. 


## Downloads
1. Aug 17 - 5445 Records were downloaded in 7303.2 seconds - According to count on Health Inspections report website there is are a total of 5453 records.  Need to investigate the missing records.
2. Aug 17 - 5453 Records were downloaded in 7213.8 seconds - Count Matches Website Count value.
3. Sept 5 - 5453 Records were downloaded in 7180.8 seconds - Count matches website count value. (this used the xpath parsing method with Nokogiri gem)

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



------

## Data Sample of Restaurant in Mongo (Using Robomongo for the Visualization):

![screen shot 2013-09-05 at 1 58 09 am](https://f.cloud.github.com/assets/1994838/1086089/53bf143e-15f0-11e3-9f80-0161579bc1bb.png)
![screen shot 2013-09-05 at 1 58 37 am](https://f.cloud.github.com/assets/1994838/1086090/5533113a-15f0-11e3-9ef7-70c5024623b1.png)

-----

### Graphs for first round of Sample analysis
![screen shot 2013-09-06 at 4 31 01 pm](https://f.cloud.github.com/assets/1994838/1099315/319ea35c-1734-11e3-99d9-d4c3939b8b03.png)
![screen shot 2013-09-06 at 4 30 33 pm](https://f.cloud.github.com/assets/1994838/1099316/31aedd44-1734-11e3-8242-b3377a1b9414.png)
![screen shot 2013-09-06 at 4 30 38 pm](https://f.cloud.github.com/assets/1994838/1099317/31b0070a-1734-11e3-90ca-01340226a3c4.png)
![screen shot 2013-09-06 at 4 30 28 pm](https://f.cloud.github.com/assets/1994838/1099318/31b00552-1734-11e3-943d-8b5533d0b356.png)




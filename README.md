[![Code Climate](https://codeclimate.com/github/StephenOTT/ottawa-heath-inspection-scrape-ruby.png)](https://codeclimate.com/github/StephenOTT/ottawa-heath-inspection-scrape-ruby)

ottawa-heath-inspection-scrape-ruby
===================================

Downloading of Ottawa Health Inspection Data with Ruby into MongoDB database

----


1. Install MongoDB and start default mongodb setup
2. Run Ruby script

All data will download into mongodb database.  Each company.restaurant is a single object in mongo.  Any inspections are sub-documents in Mongo.


## Notes:

1. Duration of downloading all data from Health inspection website is about 2 hours.  This is because each webpage must be downloaded individually.
2. All data is downloaded into the Mongodb database
3. 


## Downloads
1. Aug 17 - 5445 Records were downloaded in 7303.2 seconds - According to count on Health Inspections report website there is are a total of 5453 records.  Need to investigate the missing records

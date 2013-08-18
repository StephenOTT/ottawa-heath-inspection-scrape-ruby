require "nori"
require 'rest_client'
require 'mongo'
require 'xmlsimple'
require 'date'
	
include Mongo

class DownloadHealthInspections

	def initialize
		
		# MongoDB client and DB credential information
		@client = MongoClient.new('localhost', 27017)
		@db = @client['HealthInspections']
		@coll = @db['Inspections']
		@coll.remove

		# Class variable for the initial Rest Client Call that grabs listing of Restaurants in the downloadHealthListXML method
		@noResults = false


		self.downloadHealthListXML

	end

	def downloadHealthListXML
		
		# Class variable for keeping track of the pagination of Restaurant listings
		@count = 0
		
		# Runs until the @Count value is greater than the @numFound value found in the parsedXML value in the parseHelathListXML method
		while @noResults == false  do
		   response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=results_en&qt=fsi_s&sq_app_id=fsi&sq_keywords=&sq_field=fname&sq_fs_ftcd=&sq_fs_fwcd=&sort=fs_fnm+asc%2Cscore+desc&cookie=t&start=' + @count.to_s
	   
		   #Count is incremented by 15 for each pass through the loop becuase the Restraunt Site will provide a max of 15 results at a time
		   @count += 15
		   
		   # Debug Code for showing the current @count value
		   puts "Count: #{@count}"

		   self.parseHealthListXML(response)
		end
	end

	def parseHealthListXML(xmlData)
		parsedData = Nori.new
		parsedXML = parsedData.parse(xmlData)
		if @count >= parsedXML["response"]["result"]["@numFound"].to_i + 15
			puts "All results returned"
			@noResults=true
		else
			self.processHealthList(parsedXML)
		end

	end

	def processHealthList(dataToParse)
		healthList = dataToParse["response"]["result"]["doc"]
		healthList.each do |y|
			#puts y["str"][0]
			response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=details_en&cookie=t&sq_fs_fdid=' + y["str"][0]
			#puts "Health Data Response:"
			#puts response
			self.parseHealthRecordSingle(response)
		end 
	end

	def parseHealthRecordSingle(healthRecord)
  		parsedXML = XmlSimple.xml_in(healthRecord, { 'KeyAttr' => 'name', 'ContentKey' => '-content'} )

		parsedXMLLevelAdjust = parsedXML["result"]
		puts parsedXMLLevelAdjust
		puts parsedXMLLevelAdjust[0]["doc"][0]["str"]["fs_fstlu"][0..-5]

		self.convertDatesForMongo(parsedXMLLevelAdjust)
	end

	def convertDatesForMongo(parsedXML)
		
		# Fixes Date Strings in Facility/Restarant information
		# If statement is used to ensure that the date is not null otherway the strptime would throw a exception if it was null
		# If Statement is only used because of data inconsistancies with Health Inspection Data
		if parsedXML[0]["doc"][0]["str"]["fs_fcr_date"] != nil
			parsedXML[0]["doc"][0]["str"]["fs_fcr_date"] = DateTime.strptime(parsedXML[0]["doc"][0]["str"]["fs_fcr_date"][0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
		end

		if parsedXML[0]["doc"][0]["str"]["fs_fefd"] != nil
			parsedXML[0]["doc"][0]["str"]["fs_fefd"] = DateTime.strptime(parsedXML[0]["doc"][0]["str"]["fs_fefd"][0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
		end

		if parsedXML[0]["doc"][0]["str"]["fs_fstlu"] != nil
			parsedXML[0]["doc"][0]["str"]["fs_fstlu"] = DateTime.strptime(parsedXML[0]["doc"][0]["str"]["fs_fstlu"][0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
		end

		# Fixes all English Inspection date strings
		#First if statement checks to see if there are any inspections that need to be modified.  This is done by checking to see if the fs_insp_en hash in empty/null
		if parsedXML[0]["doc"][0]["arr"]["fs_insp_en"].empty? == false
			parsedXML[0]["doc"][0]["arr"]["fs_insp_en"]["inspection"].each do |y|
				if y["inspectiondate"] != nil
					y["inspectiondate"] = DateTime.strptime(y["inspectiondate"][0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
				end

				if y["closuredate"] != nil
					y["closuredate"] = DateTime.strptime(y["closuredate"][0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
				end
			end
		end

		# Fixes all French Inspection date string
		#First if statement checks to see if there are any inspections that need to be modified.  This is done by checking to see if the fs_insp_fr hash in empty/null
		if parsedXML[0]["doc"][0]["arr"]["fs_insp_fr"].empty? == false	
			parsedXML[0]["doc"][0]["arr"]["fs_insp_fr"]["inspection"].each do |y|
				if y["inspectiondate"] != nil
					y["inspectiondate"] = DateTime.strptime(y["inspectiondate"][0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
				end

				if y["closuredate"] != nil
					y["closuredate"] = DateTime.strptime(y["closuredate"][0..-5], '%Y-%m-%d %H:%M:%S').to_time.utc
				end
			end
		end

		# Send fixed parsedXML into MongoDB
		self.putHealthXMLinMongo(parsedXML)
	end

	def putHealthXMLinMongo(mongoPayload)
		@coll.insert(mongoPayload)
	end

	def analyzeCountofRestaurantNames
		return countOfRestaurantName = @coll.aggregate([
		    { "$project" => {restaurant_name: {"$month" => "$created_at"}, state: 1}},
		    { "$group" => {_id: {"created_month" => "$created_month", state: "$state"}, number: { "$sum" => 1 }}},
		    { "$sort" => {"_id.created_month" => 1}}
		])
	end
end




start = DownloadHealthInspections.new







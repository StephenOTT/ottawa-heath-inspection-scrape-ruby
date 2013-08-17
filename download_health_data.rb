require "nori"
require 'rest_client'
require 'mongo'
require 'xmlsimple'
	
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
		   response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=results_en&qt=fsi_s&sq_app_id=fsi&sq_keywords=&sq_field=fname&sq_fs_ftcd=&sq_fs_fwcd=&sort=fs_insp_sort+asc%2Cscore+desc&cookie=t&start=' + @count.to_s
	   
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
		if @count >= parsedXML["response"]["result"]["@numFound"].to_i
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
		self.putHealthXMLinMongo(parsedXML)
	end

	def putHealthXMLinMongo(mongoPayload)
		@coll.insert(mongoPayload)
	end

end




start = DownloadHealthInspections.new







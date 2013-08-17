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

		self.downloadHealthListXML

	end

	def downloadHealthListXML
		# TODO Add support for paging through all pages of content.  Use response.code to determine when no response if provided?
		
		responseCode = 200
		count = 0
	
	
		while responseCode == 200  do
		   response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=results_en&qt=fsi_s&sq_app_id=fsi&sq_keywords=&sq_field=fname&sq_fs_ftcd=&sq_fs_fwcd=&sort=fs_insp_sort+asc%2Cscore+desc&cookie=t&start=' + count.to_s
		   responseCode = response.code
		   puts response
		   count += 15

		   self.parseHealthListXML(response)
	
		   puts responseCode
		end
	end

	def parseHealthListXML(xmlData)
		parsedData = Nori.new
		parsedXML = parsedData.parse(xmlData)
		puts parsedXML
		self.processHealthList(parsedXML)
	end

	def processHealthList(dataToParse)
		healthList = dataToParse["response"]["result"]["doc"]
		healthList.each do |y|
			puts y["str"][0]
			#self.downloadHealthRecordsXML(y["str"][0])
			response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=details_en&cookie=t&sq_fs_fdid=' + y["str"][0]
			puts "Health Data Response:"
			puts response
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







require 'rest_client'
require 'mongo'
require 'xmlsimple'

include Mongo

class DownloadHealthInspections

	def initialize
		
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
		   puts response
		   count += 15
		   self.parseHealthListXML(response)
		   responseCode = response.code
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
			self.parseHealthRecordSingle(response)
		end 
	end

	def downloadHealthRecordsXML(healthRecordSingleID)

		
		#response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=details_en&sq_fs_fdid=7FF5646A-9116-4765-85BE-F032459E9332&cookie=t'
		#return response
	end

	def parseHealthRecordSingle(healthRecord)
		
		parsedData = Nori.new
		temp = parsedData.parse (healthRecord)
		puts temp
		#puts temp['str'].attributes.to_s
		self.putHealthXMLinMongo(temp)

		


	end



	def putHealthXMLinMongo(mongoPayload)
		@coll.insert(mongoPayload)
	end

end


start = DownloadHealthInspections.new







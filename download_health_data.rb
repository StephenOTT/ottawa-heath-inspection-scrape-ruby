require 'rest_client'
require 'mongo'
require 'xmlsimple'
require 'date'
require 'sinatra'
require 'chartkick'
require 'erb'
require 'pp'
require 'nokogiri'


include Mongo

class DownloadHealthInspections

	def initialize
		
		# MongoDB client and DB credential information
		@client = MongoClient.new('localhost', 27017)
		@db = @client['HealthInspections']
		@coll = @db['Inspections']
		
		# Clears out the collection - Primarly used for Testing/Debug but has production reasons as well
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
		parsedXML = XmlSimple.xml_in(xmlData, { 'KeyAttr' => 'name', 'ContentKey' => '-content'} )
		if @count >= parsedXML["result"][0]["numFound"].to_i + 15
			puts "All results returned"
			@noResults=true
		else
			self.processHealthList(parsedXML)
		end

	end

	def processHealthList(dataToParse)
		healthList = dataToParse["result"][0]["doc"]
		healthList.each do |y|
			response = RestClient.get 'http://app06.ottawa.ca/cgi-bin/search/inspections/q.pl?ss=details_en&cookie=t&sq_fs_fdid=' + y["str"]["fs_fdid"]
			self.parseHealthRecordSingle(response)
		end 
	end

	def parseHealthRecordSingle(healthRecord)
  		puts healthRecord
		parsedXML = Nokogiri::XML(healthRecord)
		#puts parsedXML
		#selectAllEnglishInspectionData = "response/result/doc/arr[@name='fs_insp_en']//*"
		
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
		# First if statement checks to see if there are any inspections that need to be modified.  This is done by checking to see if the fs_insp_en hash in empty/null
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
		# First if statement checks to see if there are any inspections that need to be modified.  This is done by checking to see if the fs_insp_fr hash in empty/null
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
end


class AnalyzeHealthInspectionData

	def initialize
		# MongoDB client and DB credential information
		@client = MongoClient.new('localhost', 27017)
		@db = @client['HealthInspections']
		@coll = @db['Inspections_copy_5453']
	
	end

	def analyzeRestaurantNameCount
		return restaurantNameCount = @coll.aggregate([
		    { "$project" => {doc:{str:{fs_fnm: 1}}}},
		    { "$group" => {_id: "$doc.str.fs_fnm", number: { "$sum" => 1 }}},
		    { "$sort" => {"_id" => 1 }}
		])
	end

	def analyzeRestaurantCategoryCount
		return restaurantCategoryCount = @coll.aggregate([
		    { "$project" => {doc:{str:{fs_ft_en: 1}}}},
		    { "$group" => {_id: "$doc.str.fs_ft_en", number: { "$sum" => 1 }}},
		    { "$sort" => {"_id" => 1 }}
		])
	end

	def analyzeRestaurantStreetCount
		return restaurantStreetCount = @coll.aggregate([
		    { "$project" => {doc:{str:{fs_fss: 1}}}},
		    { "$group" => {_id: "$doc.str.fs_fss", number: { "$sum" => 1 }}},
		    { "$sort" => {"_id" => 1 }}
		])
	end

	def analyzeRestaurantCreationDateCount
		return restaurantCreationDateCount = @coll.aggregate([
		    { "$project" => {doc:{str:{fs_fcr_date: 1}}}},
		    { "$group" => {_id: "$doc.str.fs_fcr_date", number: { "$sum" => 1 }}},
		    { "$sort" => {"_id" => 1 }}
		])
	end

	def analyzeRestaurantsCreatedPerMonth
		return restaurantsCreatedPerMonth = @coll.aggregate([
		    { "$project" => {created_month: {"$month" => "$doc.str.fs_fcr_date"}}},
		    { "$group" => {_id: {"created_month" => "$doc.str.fs_fcr_date"}, number: { "$sum" => 1 }}},
		    { "$sort" => {"_id.created_month" => 1}}
		])

	end



	def produceChart(data)

		values = []
		legend = []

		data.each do |x|
			legend.push(x["_id"][0])
			values.push(x["number"])
		end

			return chartURL = Gchart.bar(:title => "Event Types",
        	:data => values, 
        	#:bar_colors => 'FF0000,267678,FF0055,0800FF,00FF00',
        	:stacked => false, :size => '500x900',
        	:legend => legend)
	end




end


class MyApp < Sinatra::Base


#start = DownloadHealthInspections.new
analyze = AnalyzeHealthInspectionData.new

  get '/' do

    @foo = 'erb23'
    analyze = AnalyzeHealthInspectionData.new
    #@values = analyze.analyzeRestaurantsCreatedPerMonth.to_s
    @pie = pie_chart(analyze.analyzeRestaurantCategoryCount)
    @bar = line_chart(analyze.analyzeRestaurantCategoryCount)
  	@column = column_chart(analyze.analyzeRestaurantCategoryCount)


    erb :index
  end
end




start = DownloadHealthInspections.new
#analyze = AnalyzeHealthInspectionData.new
#MyApp.run!
#puts "************************************************** Restarant Name Count:"
#puts analyze.analyzeRestaurantNameCount
#puts "************************************************** Restarant Category Count:"
#puts analyze.analyzeRestaurantCategoryCount

#puts "************************************************** Restarant Category Created Per Month Count:"
#puts analyze.analyzeRestaurantsCreatedPerMonth

#puts analyze.produceChart(analyze.analyzeRestaurantCategoryCount)

#puts "************************************************** Restarants Per Street Count:"
#puts analyze.analyzeRestaurantStreetCount
#puts "************************************************** Restarants Creation Date Count:"
#puts analyze.analyzeRestaurantCreationDateCount
#dog = analyze.analyzeRestaurantCategoryCount


get '/' do
	code = '<script src="//www.google.com/jsapi"></script> <script src="//chartkick.js"></script>	<%= pie_chart({"Football" => 10, "Basketball" => 5}) %>	<%= pie_chart [["Football", 10], ["Basketball", 5]] %>'
	erb code

end

#dog = analyze.analyzeRestaurantCategoryCount